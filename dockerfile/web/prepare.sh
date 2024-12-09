#!/bin/bash
set -ex

PYTHON_VERSION=${PYTHON_VERSION:-3.11.11}
DBEAVER_VERSION=${DBEAVER_VERSION:-22.3.4}
CHROME_VERSION=${CHROME_VERSION:-129.0.6668.71}
CHROME_DRIVER_VERSION=${CHROME_DRIVER_VERSION:-129.0.6668.91}
TINKER_VERSION=${TINKER_VERSION:-v0.2.0}
OPENSSH_VERSION=${OPENSSH_VERSION:-v9.4.0.0}

DOWNLOAD_URL=https://download.jumpserver.org

PROJECT_DIR=$(cd `dirname $0`; pwd)
if [ -d "/opt/lina" ] && [ -d "/opt/luna" ]; then
    PROJECT_DIR=/
fi

cd ${PROJECT_DIR} || exit 1

mkdir -p ${PROJECT_DIR}/opt/download/applets
cd ${PROJECT_DIR}/opt/download/applets
wget --no-clobber -O chromedriver-${CHROME_DRIVER_VERSION}-win64.zip https://github.com/jumpserver-dev/Chrome-Portable-Win64/releases/download/${CHROME_DRIVER_VERSION}/chromedriver-win64.zip
wget --no-clobber -O chrome-${CHROME_VERSION}-win.zip https://github.com/jumpserver-dev/Chrome-Portable-Win64/releases/download/${CHROME_VERSION}/chrome-win.zip
wget --no-clobber ${DOWNLOAD_URL}/public/dbeaver-ce-${DBEAVER_VERSION}-x86_64-setup.exe
wget --no-clobber ${DOWNLOAD_URL}/public/dbeaver-patch-${DBEAVER_VERSION}-x86_64-setup.msi
wget --no-clobber ${DOWNLOAD_URL}/public/Tinker_Installer_${TINKER_VERSION}.exe
wget --no-clobber https://github.com/jumpserver-dev/Python-Embed-Win64/releases/download/${PYTHON_VERSION}/jumpserver-tinker-python-${PYTHON_VERSION}-win64.zip

mkdir -p ${PROJECT_DIR}/opt/download/public
cd ${PROJECT_DIR}/opt/download/public || exit 1
wget --no-clobber https://github.com/PowerShell/Win32-OpenSSH/releases/download/${OPENSSH_VERSION}p1-Beta/OpenSSH-Win64-${OPENSSH_VERSION}.msi