@echo off

:: Set environment variables
set PYTORCH_VERSION=2.3.0
set TORCHVISION_VERSION=0.18.0
set TORCH_INDEX_URL="https://download.pytorch.org/whl/cu121"
set TORCH_COMMAND="pip install torch==${PYTORCH_VERSION} torchvision==${TORCHVISION_VERSION} --extra-index-url ${TORCH_INDEX_URL}"

set GRADIO_AUTH=0
set GRADIO_USER=
set GRADIO_PASS=

set SD_MODEL_PATH=%cd%\models\Stable-diffusion
set SD_MODEL_URL=https://civitai.com/api/download/models/20414
set SD_MODEL_NAME=realismEngine_v10.safetensors

set VENV_DIR=venv
:: Define the packages to install
set check_choco_packages=mingw llvm

:: Check if GRADIO_USER is set
if %GRADIO_AUTH%==1 (
    echo GRADIO AUTH IS ENABLED
    set auth= --gradio-auth=%GRADIO_USER%:%GRADIO_PASS%
) else (
    echo GRADIO AUTH IS DISABLED
    set auth=
)

python -c "import tqdm; print(tqdm.__version__)" 2>nul
if %errorlevel% neq 0 (
    conda install requests tqdm -c conda-forge
)

:: Download the default SD model using the Python script
if not exist "%SD_MODEL_PATH%\%SD_MODEL_NAME%" (
    echo Downloading the default SD model: "%SD_MODEL_URL% (%SD_MODEL_NAME%)"
    python scripts/download_model.py "%SD_MODEL_URL%" "%SD_MODEL_PATH%"
    if %errorlevel% neq 0 (
        echo Failed to download %SD_MODEL_NAME% model
        exit /b 1
    )
    echo Download completed
)

echo Running webui.bat
:: Run the web UI script with specified options
.\webui.bat --skip-python-version-check --share --enable-insecure-extension-access --no-download-sd-model --xformers --no-half-vae %auth%
