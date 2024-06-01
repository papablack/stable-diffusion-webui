

set PYTORCH_VERSION=2.3.0
set TORCHVISION_VERSION=0.18.0
set PYTHON=
set GIT=
set VENV_DIR=
set COMMANDLINE_ARGS=
set TORCH_INDEX_URL="https://download.pytorch.org/whl/cu121"
set TORCH_COMMAND="pip install torch==%PYTORCH_VERSION% torchvision==%TORCHVISION_VERSION% --extra-index-url https://download.pytorch.org/whl/cu121"
set MSBUILD_PATH="C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\BuildTools\\VC\\Auxiliary\\Build\\\vcvars64.bat"
set XFORMERS_PACKAGE="xformers"

set GRADIO_USER=""
set GRADIO_PASS=""

:: Define the packages to install
set check_choco_packages="mingw llvm"

pip install torch==%PYTORCH_VERSION% torchvision==%TORCHVISION_VERSION% --extra-index-url https://download.pytorch.org/whl/cu121

:: Check if GRADIO_USER is set
if "%GRADIO_USER%"=="" (
    echo "GRADIO_USER is not set."
    set auth=""
) else (
    :: Check if GRADIO_PASS is set
    if "%GRADIO_PASS%"=="" (
        echo GRADIO_PASS is not set.
        set auth=""
    ) else (
        :: Construct the auth variable
        set auth="--gradio-auth=%GRADIO_USER%:%GRADIO_PASS%"
    )
)

:: Check if Chocolatey is installed
where choco >nul 2>nul
if %errorlevel% neq 0 (
    echo Chocolatey is not installed. Please install Chocolatey and try again.
    echo "https://chocolatey.org/install"
    exit /b 1
)

:: Loop through each package
for %%p in (%check_choco_packages%) do (
    :: Check if the package is already installed
    choco list --local-only %%p >nul 2>nul
    if %errorlevel% equ 0 (
        echo Package %%p is already installed.
    ) else (
        :: Install the package silently
        echo Installing package %%p...
        choco install %%p -y
        if %errorlevel% neq 0 (
            echo Failed to install package %%p.
        )

        echo Installation completed.
    )
)

python -c "import wheel; print(wheel.__version__)" 2>nul
if %ERRORLEVEL% neq 0 (
    echo "Installing Wheels..."
    pip install wheel
)

cd repositories

if not exist "xformers" (
    echo "Installing XFormers..."

    git clone --recurse-submodules https://github.com/facebookresearch/xformers.git
)

python -c "import xformers; print(xformers.__version__)" 2>nul
if %ERRORLEVEL% neq 0 (        
    cd xformers

    if not exist dist\xformers-*.whl (
        echo Building XFormers...
        call %MSBUILD_PATH%

        python setup.py sdist bdist_wheel
    ) else (
        echo .whl file already exists, skipping build.
    )

    for %%f in (dist\xformers-*.whl) do (
        pip install dist\%%f
    )

    python -c "import xformers; print(xformers.__version__)"

    cd ..
)


if not exist "scikit-image" (
    git clone https://github.com/scikit-image/scikit-image.git
)

cd scikit-image

powershell -Command "(gc skimage\feature\_texture.pxd) -replace 'cdef int _multiblock_lbp\(', 'cdef int _multiblock_lbp\(\) except +' | Out-File -encoding ASCII skimage\feature\_texture.pxd"
powershell -Command "(gc skimage\feature\_cascade.pxd) -replace 'cdef int classify\(', 'cdef int classify\(\) except +' | Out-File -encoding ASCII skimage\feature\_cascade.pxd"
powershell -Command "(gc skimage\feature\_cascade.pxd) -replace 'cdef int __pyx_fuse_0_multiblock_lbp\(', 'cdef int __pyx_fuse_0_multiblock_lbp\(\) except +' | Out-File -encoding ASCII skimage\feature\_cascade.pxd"
powershell -Command "(gc skimage\feature\_texture.pxd) -replace 'cdef int __pyx_fuse_8integrate\(', 'cdef int __pyx_fuse_8integrate\(\) except +' | Out-File -encoding ASCII skimage\feature\_texture.pxd"
powershell -Command "(gc skimage\feature\_texture.pxd) -replace 'cdef int __pyx_fuse_9integrate\(', 'cdef int __pyx_fuse_9integrate\(\) except +' | Out-File -encoding ASCII skimage\feature\_texture.pxd"

pip install .

cd ../../

REM call ./webui.bat --skip-python-version-check --share --enable-insecure-extension-access --no-download-sd-model --xformers --no-half-vae %auth%