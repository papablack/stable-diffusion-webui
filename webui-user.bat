@echo off

set PYTHON=
set GIT=
set VENV_DIR=
set COMMANDLINE_ARGS=
set TORCH_INDEX_URL="https://download.pytorch.org/whl/cu121"
set TORCH_COMMAND="pip install torch==2.2.2 torchvision==0.17.2 --extra-index-url https://download.pytorch.org/whl/cu121"

call webui.bat --skip-python-version-check --share --
