#!/bin/bash
set -e  # Enable exit on error

export PYTORCH_VERSION=2.3.0
export TORCHVISION_VERSION=0.18.0
export TORCH_INDEX_URL="https://download.pytorch.org/whl/cu121"
export TORCH_COMMAND="pip install torch==${PYTORCH_VERSION} torchvision==${TORCHVISION_VERSION} --extra-index-url ${TORCH_INDEX_URL}"

export GRADIO_AUTH=
export GRADIO_USER=
export GRADIO_PASS=

script_dir=$(dirname "$(realpath "$0")")
export SD_MODEL_PATH="$script_dir\models\Stable-diffusion"
export SD_MODEL_URL="https://civitai.com/api/download/models/20414"
export SD_MODEL_NAME=realismEngine_v10.safetensors

if [ ! -f "$SD_MODEL_PATH/$SD_MODEL_NAME" ]; then
    echo "Downloading the default SD model: $SD_MODEL_URL ($SD_MODEL_NAME)..."
    
    # Download the model using a Python script
    python scripts/download_model.py "$SD_MODEL_URL" "$SD_MODEL_PATH"
    
    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Failed to download the default SD model."
        exit 1
    fi
    
    echo "Download completed."
fi

./webui.sh --skip-python-version-check --share --enable-insecure-extension-access --no-download-sd-model --xformers --no-half-vae $auth