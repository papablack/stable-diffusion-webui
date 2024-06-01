#!/bin/bash
set -e  # Enable exit on error

export PYTORCH_VERSION=2.3.0
export TORCHVISION_VERSION=0.18.0
export TORCH_INDEX_URL="https://download.pytorch.org/whl/cu121"
export TORCH_COMMAND="pip install torch==${PYTORCH_VERSION} torchvision==${TORCHVISION_VERSION} --extra-index-url ${TORCH_INDEX_URL}"

export XFORMERS_PACKAGE="xformers"

export GRADIO_USER=""
export GRADIO_PASS=""

# Define the packages to install
check_apt_packages=("mingw-w64" "llvm")

# Install PyTorch and Torchvision
pip install torch==${PYTORCH_VERSION} torchvision==${TORCHVISION_VERSION} --extra-index-url ${TORCH_INDEX_URL}

# Check if GRADIO_USER is set
if [ -z "$GRADIO_USER" ]; then
    echo "GRADIO_USER is not set."
    auth=""
else
    # Check if GRADIO_PASS is set
    if [ -z "$GRADIO_PASS" ]; then
        echo "GRADIO_PASS is not set."
        auth=""
    else
        # Construct the auth variable
        auth="--gradio-auth=${GRADIO_USER}:${GRADIO_PASS}"
    fi
fi

# Update package list and install apt packages
sudo apt update


for package in "${check_apt_packages[@]}"; do
    # Check if the package is already installed
    if dpkg -l | grep -q "^ii  $package"; then
        echo "Package $package is already installed."
    else
        echo "Following packages are required: $check_apt_packages"
        exit 1
    fi
done

# Check if wheel is installed
if ! python -c "import wheel" &> /dev/null; then
    echo "Installing wheel..."
    pip install wheel
fi

# Check if XFormers is already installed
if ! python -c "import xformers" &> /dev/null; then
    cd repositories
    echo "Installing XFormers..."

    # Clone xformers repository if not already cloned
    if [ ! -d "xformers" ]; then
        git clone --recurse-submodules https://github.com/facebookresearch/xformers.git
    fi

    cd xformers

    if [ ! -f dist/xformers.whl ]; then
        echo "Building XFormers..."

        python setup.py sdist bdist_wheel
        for file in dist/xformers-*.whl; do
            mv "$file" dist/xformers.whl
        done
        for file in dist/xformers-*.tar.gz; do
            mv "$file" dist/xformers.tar.gz
        done
    else
        echo ".whl file already exists, skipping build."
    fi

    pip install dist/xformers.whl

    python -c "import xformers"

    cd ..

    # Clone and patch scikit-image
    git clone https://github.com/scikit-image/scikit-image.git
    cd scikit-image
    
    # Apply patches to add exception declarations
    sed -i 's/cdef int _multiblock_lbp(...)/cdef int _multiblock_lbp(...) except +/g' skimage/feature/_texture.pxd
    sed -i 's/cdef int classify(...)/cdef int classify(...) except +/g' skimage/feature/_cascade.pxd
    sed -i 's/cdef int __pyx_fuse_0_multiblock_lbp(...)/cdef int __pyx_fuse_0_multiblock_lbp(...) except +/g' skimage/feature/_cascade.pxd
    sed -i 's/cdef int __pyx_fuse_8integrate(...)/cdef int __pyx_fuse_8integrate(...) except +/g' skimage/feature/_texture.pxd
    sed -i 's/cdef int __pyx_fuse_9integrate(...)/cdef int __pyx_fuse_9integrate(...) except +/g' skimage/feature/_texture.pxd

    python setup.py build_ext --inplace
    pip install .

    cd ../..
fi

./webui.sh --skip-python-version-check --share --enable-insecure-extension-access --no-download-sd-model --xformers --no-half-vae $auth
