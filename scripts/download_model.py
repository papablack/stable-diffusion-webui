import requests
from tqdm import tqdm
import os
import sys
from urllib.parse import urlparse, parse_qs, unquote
from datetime import datetime

def get_civitai_model_name(url):
    response = requests.get(url, allow_redirects=False)
    if "Location" in response.headers:
        redirected_url = response.headers["Location"]
        quer = parse_qs(urlparse(redirected_url).query)
        if "response-content-disposition" in quer:
            disp_val = quer["response-content-disposition"][0].split(";")
            for vals in disp_val:
                if vals.strip().startswith("filename="):
                    filenm=unquote(vals.split("=", 1)[1].strip())
                    return filenm.replace("\"","")            
    filetime = datetime.now().strftime("%Y_%m_%d__%H_%M")
    return f"unnamed_model_{filetime}.safetensors"

def download_model(url, download_directory, local_filename = None):
    if not local_filename:
        local_filename = download_directory + '/' + get_civitai_model_name(url)

    print(local_filename)

    if not os.path.exists(os.path.dirname(local_filename)):
        os.makedirs(os.path.dirname(local_filename))    
    
    

    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        total_size = int(r.headers.get('content-length', 0))
        block_size = 1024  # 1 KB
        try:
            t = tqdm(total=total_size, unit='iB', unit_scale=True)
            with open(local_filename, 'wb') as f:
                for chunk in r.iter_content(chunk_size=block_size):
                    t.update(len(chunk))
                    f.write(chunk)
            t.close()
            if total_size != 0 and t.n != total_size:
                print("ERROR, something went wrong")
        except:
            raise Exception("MODEL DOWNLOAD ERROR")        

if __name__ == "__main__":
    if len(sys.argv) < 3 or len(sys.argv) > 4:
        print("Usage: python download_with_progress.py <url> <output_path:optional>")
        sys.exit(1)
    
    url = sys.argv[1]
    download_dir = sys.argv[2] if len(sys.argv) > 2 else None  
    local_filename = sys.argv[3] if len(sys.argv) > 3 else None  

    download_model(url, download_dir, local_filename)
