#!/bin/bash

# Author:	Seba Collado (scollado@ujaen.es)
# Description:	Script to install Python 2.7 and OpenCV 3.0 on Ubuntu 16.04 x64
# Based on http://www.pyimagesearch.com/2015/06/22/install-opencv-3-0-and-python-2-7-on-ubuntu/

# Check root condition
if [ "$EUID" -ne 0 ]
then
	echo "Please run as root"
	exit
fi

# Check x64 system
if [ $(uname -m) != "x86_64" ]
then
	echo "This scripts only works on x64 based systems"
	exit
fi

cd ~
echo "-- Updating repositories"
sudo apt-get update && sudo apt-get -y upgrade
echo "-- Installing libraries"
sudo apt-get -y install build-essential cmake git pkg-config
sudo apt-get -y install libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev
sudo apt-get -y install libgtk2.0-dev
sudo apt-get -y install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get -y install libatlas-base-dev gfortran
echo "-- Installing pip"
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
sudo pip install virtualenv virtualenvwrapper
sudo rm -rf ~/.cache/pip
echo "-- Preparing virtualenv"
echo '# virtualenv and virtualenvwrapper' >> ~/.bashrc
echo 'export WORKON_HOME=$HOME/.virtualenvs' >> ~/.bashrc
echo 'source /usr/local/bin/virtualenvwrapper.sh' >> ~/.bashrc
source ~/.bashrc
mkvirtualenv cv
echo "-- Installing python2.7"
sudo apt-get -y install python2.7-dev
echo "-- Installing numpy"
pip install numpy
echo "-- Downloading OpenCV 3.0.0"
cd ~
git clone https://github.com/opencv/opencv.git
cd opencv
git checkout 3.0.0
echo "-- Downloading OpenCV 3.0.0 contrib"
cd ~
git clone https://github.com/Itseez/opencv_contrib.git
cd opencv_contrib
git checkout 3.0.0
echo "-- Preparing build"
cd ~/opencv
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D INSTALL_C_EXAMPLES=ON \
	-D INSTALL_PYTHON_EXAMPLES=ON \
	-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
	-D BUILD_EXAMPLES=ON ..
echo "-- Building OpenCV"
make -j4
echo "-- Installing OpenCV"
sudo make install
sudo ldconfig
cd ~/.virtualenvs/cv/lib/python2.7/site-packages/
ln -s /usr/local/lib/python2.7/site-packages/cv2.so cv2.so
