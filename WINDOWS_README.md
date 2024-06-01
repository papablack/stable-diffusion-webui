# Install builders in Powershell

1. Start elevated Powershell (Admin priviliges)
2. Install chocolatey: 

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

3. Install mingw & llvm packages && conda:

```powershell
choco install mingw -y
choco install llvm -y
choco install anaconda3 -y
```

4. (Optional - Recommended) [Download and install MS Build Tools](https://aka.ms/vs/16/release/vs_buildtools.exe) (You want C++ build tools for rare need of extension build) 

5. Create conda env:

    *Make sure you opened your powershell or VSCode through Anaconda Navigator or Anaconda Shells*

```bash
conda create --name ml
```

6. Activate conda env:

```bash
conda activate ml
```

7. Install and start server:

    *Takes two executions at first install*

```bash
.\webui-user.bat    
```

