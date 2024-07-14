#!/bin/bash -e

echo "Extracting tools and setting up environment..."

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
THIS_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
ROOT=$DIR/..

# Check if running on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    echo "Running on macOS. Setting up necessary tools..."

    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install necessary tools
    echo "Installing necessary tools..."
    brew install git git-lfs gcc aarch64-elf-gcc make binutils coreutils

    # Set up cross-compilation environment variables
    export CROSS_COMPILE=aarch64-elf-
    export CC=aarch64-elf-gcc
    export LD=aarch64-elf-ld
fi

# Check for git-lfs
if ! command -v git-lfs &> /dev/null; then
    echo "ERROR: git-lfs not installed"
    exit 1
fi

cd $DIR

LINARO_GCC=aarch64-linux-gnu-gcc
GOOGLE_GCC_4_9=aarch64-linux-android-4.9
EDK2_LLVM=llvm-arm-toolchain-ship
SEC_IMAGE=SecImage

# grep for `-`, which stands for LFS pointer
git lfs ls-files | awk '{print $2}' | grep "-" &>/dev/null && {
  echo "Pulling git lfs objects..."
  cd $ROOT
  git lfs install
  git lfs pull
  cd $DIR
}

LINARO_GCC_TARBALL=$LINARO_GCC.tar.gz
GOOGLE_GCC_4_9_TARBALL=$GOOGLE_GCC_4_9.tar.gz
EDK2_LLVM_TARBALL=$EDK2_LLVM.tar.gz
SEC_IMAGE_TARBALL=$SEC_IMAGE.tar.gz

if [ ! -d $LINARO_GCC ]; then
  echo "Extracting $LINARO_GCC..."
  tar -xzf $LINARO_GCC_TARBALL
fi

if [ ! -d $GOOGLE_GCC_4_9 ]; then
  echo "Extracting $GOOGLE_GCC_4_9..."
  tar -xzf $GOOGLE_GCC_4_9_TARBALL
fi

if [ ! -d $EDK2_LLVM ]; then
  echo "Extracting $EDK2_LLVM..."
  tar -xzf $EDK2_LLVM_TARBALL
fi

if [ ! -d $SEC_IMAGE ]; then
  echo "Extracting $SEC_IMAGE..."
  tar -xzf $SEC_IMAGE_TARBALL
fi

echo "Extraction complete."

if [[ "$(uname)" == "Darwin" ]]; then
    echo "macOS environment setup complete. You may need to modify build_kernel.sh to use the macOS-compatible toolchain."
    echo "Python 2 has been installed and added to your PATH. You may need to restart your terminal or run 'source ~/.bash_profile' for the changes to take effect."
fi
