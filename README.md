# setup_scripts
Welcome to TEK5030 `setup_scripts`. This directory contains scripts for installing the course's software dependencies on Ubuntu 18.04.

We recommend that you don't run the scripts blindly, but instead follow the information on this page. We will go through all required steps so that you might learn something along the way.

We will install the following:

- CMake, git and some other basic tools
- Eigen3 (Linear Algebra library)
- Sophus (C++ implementation of Lie Groups using Eigen)
- OpenCV 4 (Computer vision library)
- GeographicLib (Library for performing conversions between geographic, UTM, UPS, MGRS, geocentric, and local cartesian coordinates, for gravity, geoid height, and geomagnetic field calculations, and for solving geodesic problems.)
- GTSAM (Factor Graphs)
- And maybe some more...

It is assumed that you have a fresh install of Ubuntu 18.04 with nothing else on it, so we are starting from scratch. We will use a Terminal window for all our actions, so go ahead and open a new Terminal window (`Ctrl` + `Alt` + `T`).

It should be ok to just copy-paste the commands into your terminal in order to avoid typos.


## Installation step by step

### Add additional apt repositories
In Ubuntu, we install packages (libraries etc.) using a tool called `apt`. The packages are downloaded from one or more apt software repositories. An APT repository is a network server or a local directory containing deb packages and metadata files that are readable by the APT tools.
While there are thousands of application available in the default Ubuntu repositories, sometimes you may need to install software from a 3rd party repository, for example in order to get a newer version of a library than the "Long Term Support"-version available through the default repositories.

Most repositories are providing a public key to authenticate downloaded packages. The key must also be downloaded and imported.

If you are curious, read more about repositories [on the internet][How To Add Apt Repository In Ubuntu].

#### Add Kitware repository for installation of newer CMake [[3]][cmake]
The CMake version available from the default repository is version 3.10, but as CMake frequently releases important updates and bugfixes, we have nothing to lose and much to win by installing a newer version. The easiest way to do this is to add their APT repository and download from there.

```bash
# Install required packages in order to download and install the new repo.
sudo apt install apt-transport-https ca-certificates gnupg software-properties-common wget
# Download and install the key
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
# Add the repository
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
```

### Add packages

#### Install compiler, cmake, curl and git
we will install a few basic tools before proceeding with installation of course dependencies.

```bash
sudo apt install -y \
  build-essential \
  cmake \
  curl \
  git \
  wget
```

#### Install Eigen
We can install a sufficient version of Eigen with `apt`.
```bash
sudo apt install -y \
  libblas-dev \
  liblapack-dev \
  libeigen3-dev
```

#### Install Sophus
Sophus must be installed from source. We use `git` and `cmake` for this. Use `man cmake` or `cmake --help` in order to learn more.
Note that Eigen must be installed before we try to install Sophus.
```bash
# Clone the repository (download the code) from GitHub.
git clone --depth 1 https://github.com/strasdat/Sophus.git
# Configure the project
# -S: source folder
# -B: build folder (will be created automatically)
cmake -S Sophus -B Sophus/build \
 -DCMAKE_BUILD_TYPE=Release \
 -DBUILD_EXAMPLES=OFF \
 -DBUILD_TESTS=OFF
# Copy the files to /usr/local/...
sudo cmake --build Sophus/build --target install
sudo rm -rf Sophus ~/.cmake/packages/Sophus
```

###### Install GeographicLib
We are alo installing GeographicLib from source, but instead of cloning via `git` we are downloading the source code using `curl`.
Using the pipe, we are renaming the downloaded the folder for convenience.
```bash
curl -fsL https://sourceforge.net/projects/geographiclib/files/distrib/GeographicLib-1.51.tar.gz \
| tar --xform 's/GeographicLib[0-9.-]+/geographiclib/gx' -zx

cmake -S geographiclib -B geographiclib/build -DCMAKE_BUILD_TYPE=Release
# Copy the files to /usr/local/...
sudo cmake --build geographiclib/build --config release --target install
# Delete the downloaded files
sudo rm -rf geographiclib
```

###### Install GTSAM
```bash
git clone --depth 1 https://github.com/borglab/gtsam.git
cmake -S gtsam -B gtsam/build \
 -DGTSAM_BUILD_TESTS=OFF \
 -DGTSAM_WITH_EIGEN_MKL=OFF
cmake --build gtsam/build -- -j$(nproc)
sudo cmake --build gtsam/build --target install
rm -rf gtsam
```

###### Install OpenCV dependencies
```bash
# Install compiler
sudo apt-get update && sudo apt-get install -y \
  build-essential

# Install required
sudo apt install -y \
  cmake \
  cmake-qt-gui \
  git \
  libavcodec-dev \
  libavformat-dev \
  libgtk2.0-dev \
  libswscale-dev \
  pkg-config

# Install boost
sudo apt install -y \
  libboost-all-dev

# Install optional
sudo apt install -y \
  libdc1394-22-dev \
  libjpeg-dev \
  libpng-dev \
  libtbb2 \
  libtbb-dev \
  libtiff-dev \
  libvtk7-dev \
  mesa-utils \
  python3-dev \
  python3-numpy \
  qt5-default
  
# Install very optional
sudo apt install -y \
  libcanberra-gtk-module \
  libcanberra-gtk3-module
```
###### Compile OpenCV
```bash
# Convenience variable
tag=${OpenCV_VERSION:-4.0.1}

# Download opencv sources
git clone -b ${tag} --depth 1 https://github.com/opencv/opencv.git opencv-${tag}
git clone -b ${tag} --depth 1 https://github.com/opencv/opencv_contrib.git opencv_contrib-${tag}

mkdir opencv-${tag}/build
cd $_

# Build OpenCV
cmake .. \
-DCPACK_MONOLITHIC_INSTALL=ON \
-DCMAKE_BUILD_TYPE=Release \
-DBUILD_DOCS=OFF \
-DBUILD_EXAMPLES=OFF \
-DBUILD_JAVA=OFF \
-DBUILD_PROTOBUF=ON \
-DBUILD_TBB=ON \
-DBUILD_TESTS=OFF \
-DBUILD_PERF_TESTS=OFF \
-DOPENCV_ENABLE_NONFREE=ON \
-DOPENCV_EXTRA_MODULES_PATH="../../opencv_contrib-${tag}/modules/" \
-DWITH_CUDA=OFF \
-DWITH_GDAL=ON \
-DWITH_PROTOBUF=ON \
-DPROTOBUF_UPDATE_FILES=OFF \
-DWITH_QT=ON \
-DBUILD_opencv_{java,js,python}=OFF \
-DBUILD_opencv_python2=OFF \
-DBUILD_opencv_python3=ON \
-DBUILD_opencv{\
bgsegm,bioinspired,ccalib,cnn_3dobj,cvv,datasets,dnn_objdetect,dnns_easily_fooled,dpm,face,freetype,\
fuzzy,hdf,hfs,img_hash,line_descriptor,matlab,optflow,ovis,phase_unwrapping,plot,reg,rgbd,saliency,sfm,shape,stereo,\
structured_light,superres,surface_matching,text,tracking,videostab}=OFF \
-DBUILD_opencv_cuda{bgsegm,codec,filters,legacy,objdetect,stereo}=OFF \
-DBUILD_opencv_cudev=OFF 

cmake --build . --config release -- -j $(nproc) -Wno-cpp
sudo cmake --build . --target install

cd ../../
rm -rf opencv*
```





## Setup on Windows 
Tek5030 does not officially support Windows, but we have provided an Ubuntu image with dependencies already installed, which you can use with VirutalBox.


### Links to installation pages
#### CMake
https://cmake.org/install/
#### OpenCV
https://cv-tricks.com/how-to/installation-of-opencv-4-1-0-in-windows-10-from-source/
https://docs.opencv.org/4.1.0/d3/d52/tutorial_windows_install.html
#### GeographicLib
https://geographiclib.sourceforge.io/html/install.html
#### GTSAM
https://borg.cc.gatech.edu/download.html
#### RealSense
https://github.com/IntelRealSense/librealsense/blob/master/doc/distribution_windows.md



## Setup on Ubuntu 18.04
The scripts in this repo are created to install everything needed. 

```bash
sudo ./00-run-complete-setup
```

You can also choose to run each script separately.

---

[How To Add Apt Repository In Ubuntu](https://linuxize.com/post/how-to-add-apt-repository-in-ubuntu/)



[techrep]: https://www.techrepublic.com/article/how-to-create-a-custom-ubuntu-iso-with-cubic/
[multiverse]: https://linuxconfig.org/how-to-enable-disable-universe-multiverse-and-restricted-repository-on-ubuntu-20-04-lts-focal-fossa
[cmake]: https://apt.kitware.com/
[chroot]: https://www.howtogeek.com/441534/how-to-use-the-chroot-command-on-linux/
[tek5030/setup_scripts]: https://github.com/tek5030/setup_scripts
