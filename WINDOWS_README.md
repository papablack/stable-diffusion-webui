# Install builders in Powershell

1. Start elevated Powershell (Admin priviliges)
2. Install chocolatey: 

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

3. Install mingw & llvm packages:

```powershell
choco install mingw
choco install llvm
```

4. (Optional - Recommended) [Download and install MS Build Tools](https://aka.ms/vs/16/release/vs_buildtools.exe) (You want C++ build tools for rare need of extension build) 

5. Install and start server:
```bash
.\webui-user.bat    
```

