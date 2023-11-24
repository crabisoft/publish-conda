#!/bin/bash

set -e
set -o pipefail

# VARIABLES
INPUT_CONDADIR=$(env | sed -n 's/INPUT_SUB-DIRECTORY=\(.*\)/\1/p')
BUILD_CHANNELS=$(env | sed -n 's/INPUT_BUILD-CHANNELS=\(.*\)/\1/p')
UPLOAD_CHANNEL=$(env | sed -n 's/INPUT_UPLOAD-CHANNEL=\(.*\)/\1/p')
PLATFORMS=($INPUT_PLATFORMS)
STABLE=${INPUT_STABLE}
CONDA_TOKEN=${INPUT_TOKEN}
TMP_DIR=tmp_dir

# print a message
echo_msg() {
    echo "$@"
    echo ""
}
# check input parameters
check_input() {
    echo_msg "----- Checking input parameters -----"
    
    DEFAULT_PLAFORMS=("osx-64 osx-arm64 linux-64 linux-aarch64 win-64 noarch")
    for PLATFORM in "${PLATFORMS[@]}"
    do
    if ! [[ " ${DEFAULT_PLAFORMS} " =~ .*\ ${PLATFORM}\ .* ]]; then
        echo_msg "*** error: ${PLATFORM} platform not supported, only one of them: ${DEFAULT_PLAFORMS}"
        exit 1
    fi
    done

    echo "sub-directory : ${INPUT_CONDADIR}"
    echo "build-channels: ${BUILD_CHANNELS}"
    echo "upload-channel: ${UPLOAD_CHANNEL}"
    echo "platforms     : ${PLATFORMS}"
    echo "stable        : ${STABLE}"
    echo ""
}

# check existence of mandatory file
check_meta_file() {
    echo_msg "----- Check meta.yaml file existence  -----"
    if [ -n "${INPUT_CONDADIR:-}" -a  "${INPUT_CONDADIR:-}" != "." ]; then
        cd "${INPUT_CONDADIR}"
    fi

    if [ ! -f meta.yaml ]; then
        echo_msg "*** error: meta.yaml must exist in the directory that is being packaged and published."
        exit 1
    fi
}

# Setup Conda configuration
setup_conda() {
    echo_msg "----- Setup Conda configuration -----"
    # add channels
    for CHANNEL in "${CHANNELS[@]}"; do
        conda config --append channels $CHANNEL
    done
}


# Build packages
build_packages() {
    echo_msg "----- Build required package(s) -----"
    mkdir -p ${TMP_DIR}

    # build package as per meta.yaml
    conda build . --output-folder ${TMP_DIR}

    # convert package for each required platforms
    find ${TMP_DIR}/ -name *.tar.bz2 | while read file; do
        for PLATFORM in "${PLATFORMS[@]}"; do
            if [ "noarch" != $PLATFORM -a "linux-x64" != $PLATFORM ]; then
                conda convert --force --platform $PLATFORM $file  -o ${TMP_DIR}/
            fi
        done
    done
}

# Upload packages
upload_packages() {
    echo_msg "----- Upload Conda package(s) -----"

    if [ -z "${INPUT_TOKEN:-}" ]; then
        echo_msg "*** warning: skip package upload since Anaconda token not set"
        return
    fi

    conda config --set anaconda_upload yes
    export ANACONDA_API_TOKEN=${INPUT_TOKEN}

    find ${TMP_DIR}/ -name *.tar.bz2 | while read file; do
        echo "uploading $file ..."
        anaconda upload $file
    done
}


check_input
check_meta_file
setup_conda
build_packages
upload_packages
