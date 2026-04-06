#!/bin/bash

WD=$(pwd)

sudo apt update
sudo apt install wget

function funNPUSetup() {
  mkdir ${WD}/tmp
  cd  ${WD}/tmp && rm *gz *deb
  # REFs:
  # - https://docs.openvino.ai/2026/get-started/install-openvino/configurations/configurations-intel-npu.html
  # - https://github.com/intel/linux-npu-driver
  # - https://github.com/intel/linux-npu-driver/releases <-- !!!

  # STEP 1) Remove  old packages
  sudo dpkg --purge --force-remove-reinstreq \
    intel-driver-compiler-npu \
    cintel-fw-npu intel-level-zero-npu \
    intel-level-zero-npu-dbgsym

  # STEP 2: Download packages 
  readonly BASE_URL01="https://github.com/intel/linux-npu-driver/releases/download"
  readonly      VER="v1.32.0"
  readonly   DRIVER="linux-npu-driver-v1.32.0.20260402-23905121947-ubuntu2404.tar.gz"
  wget "${BASE_URL01}/${VER}/${DRIVER}"
  tar -xf                   ${DRIVER}

  # STEP 3
  sudo apt install libtbb12

  # STEP 4:
  sudo dpkg -i *.deb

  # STEP 5:
  sudo dpkg --purge --force-remove-reinstreq level-zero level-zero-devel
  readonly BASE_URL02="https://snapshot.ppa.launchpadcontent.net/kobuk-team/intel-graphics/ubuntu/20260324T100000Z"
  readonly ULR_PATH="pool/main/l/level-zero-loader/libze1_1.27.0-1~24.04~ppa2_amd64.deb"
  wget "${BASE_URL02}/${ULR_PATH}"
  sudo dpkg -i libze1_*.deb

  # STEP 6: Optional TODO: Recheck
  # sudo gpasswd -a ${USER} render
  # newgrp render
  #
  cat << __EOF
  # Reboot your system and check that hardware is setup properly like:
  ls /dev/accel/accel0
  /dev/accel/accel0            # <·· expected output
  # to receive intel_vpu state
  sudo dmesg
__EOF
}

function funGPUSetup() { # TODO:(0)
  cd ${WD}
  # Install OpenCL:
  # REF: https://docs.openvino.ai/2026/get-started/install-openvino/configurations/configurations-intel-gpu.html
  echo "GPU script pending"
}

function funPIPSetup() {
  cd ${WD}
  # Creates base virt.env. for OpenVINO
  python3 -m venv --prompt ovino .venv
  source .venv/bin/activate
  python -m pip install --upgrade pip
  pip install openvino==2026.0.0
}


funNPUSetup
funGPUSetup
# funPIPSetup # TODO:(0) Remove comment
