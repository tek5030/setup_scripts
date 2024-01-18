# setup_scripts
## Introduction
Welcome to TEK5030 `setup_scripts`!
This directory contains scripts for installing the course's software dependencies on Ubuntu 22.04.

**We recommend that you don't run the scripts blindly, but instead follow the information on this page.**   
We will go through all required steps so that you might learn something along the way.

We will install the following:

- CMake, git and some other basic tools
- Eigen3 (Linear Algebra library)
- Sophus (C++ implementation of Lie Groups using Eigen)
- OpenCV 4 (Computer vision library)
- GeographicLib (Library for performing conversions between geographic, UTM, UPS, MGRS, geocentric, and local cartesian coordinates, for gravity, geoid height, and geomagnetic field calculations, and for solving geodesic problems.)
- GTSAM (Factor Graphs)
- And maybe some more...

It is assumed that you have a fresh install of Ubuntu 22.04 with nothing else on it, so we are starting from scratch.
We will use a Terminal window for all our actions, so go ahead and open a new Terminal window (`Ctrl` + `Alt` + `T`).

It should be ok to just copy-paste the commands into your terminal in order to avoid typos.

In the commands you will often see lines ending with a backslash `\`, like
```bash
some_command \
  more \
  things
```
This is just a line continuation symbol, which is used for clarity and readability,
so the example above is equivalent to
```bash
some_command more things
```

### About additional apt repositories
In Ubuntu, we install packages (libraries etc.) using a tool called `apt`.
The packages are downloaded from one or more apt software repositories.
An APT repository is a network server or a local directory containing deb packages
and metadata files that are readable by the APT tools.
While there are thousands of application available in the default Ubuntu repositories,
sometimes you may need to install software from a 3rd party repository.
For example, we can download and install drivers and SDK for Intel® RealSense™ cameras from such a repository.
Most repositories are providing a public key to authenticate downloaded packages.
The key must also be downloaded and imported.

If you are curious, read more about repositories [on the internet][How To Add Apt Repository In Ubuntu].

## Installation step by step

#### Add Kitware repository for installation of newer CMake [[1]][cmake]
The CMake version available from the default repository is version 3.22, which is not bad at all.
However, useful updates and bugfixes are frequently released for CMake,
so we have much to win and nothing to lose by installing a newer version.
The easiest way to do this is to add their APT repository and install from there.
The procedure is updated from time to time, so it is wise to check out [https://apt.kitware.com/][cmake] to see the latest and greatest.
We can employ their installation script to save us some typing. 

```bash
# Install required packages in order to download and install the new repo.
sudo apt update
sudo apt install curl

curl -sSfL https://apt.kitware.com/kitware-archive.sh | sudo bash
```

### Add packages

#### Install compiler, cmake, curl and git
we will install a few basic tools before proceeding with installation of the dependencies.
The `-y` (or `--yes`) means that we don't want to be propmpted for whether we _really_ want to install or not.

```bash
sudo apt install -y \
  build-essential \
  ccache \
  cmake \
  git
```

#### Install Eigen
We can install a sufficient version of Eigen with `apt`.
In addition, we install blas and lapack.

```bash
sudo apt install -y \
  libblas-dev \
  liblapack-dev \
  libeigen3-dev
```

#### Install Sophus
Sophus must be installed from source.
We use `git` and `cmake` for this.
Use `man cmake` or `cmake --help` in order to learn more.
Note that Eigen must be installed before we try to install Sophus.
We specify some options to CMake in order to configure the build according to our needs.
A library may support more or less options, but the three we see below are pretty common for many libraries.

On the second last line, we utilize `cmake` also for compiling the software, using the `--build` flag.

```bash
sudo apt install -y \
  libfmt-dev

# Clone the repository (download the code) from GitHub.
git clone --depth 1 https://github.com/strasdat/Sophus.git
# Configure the project
# -S: source folder
# -B: build folder (will be created automatically)
cmake -S Sophus -B Sophus/build \
 -DCMAKE_BUILD_TYPE=Release \
 -DBUILD_SOPHUS_EXAMPLES=OFF \
 -DBUILD_SOPHUS_TESTS=OFF
# Copy the files to /usr/local/...
sudo cmake --build Sophus/build --target install
sudo rm -rf Sophus ~/.cmake/packages/Sophus
```

#### Install GeographicLib
On Ubuntu 22.04, we can install a sufficiently new version of geographiclib via `apt`, so we don't have to build from source.

```bash
sudo apt install -y \
  libgeographic-dev \
  geographiclib-tools
```

#### Install GTSAM
GTSAM has some additional dependencies that we must install before trying to compile it.
```bash
sudo apt install -y \
  libboost-all-dev \
  libtbb2-dev
```
Now we can go on.
```bash
curl -fsSL https://github.com/borglab/gtsam/archive/refs/tags/4.2.tar.gz | tar -zx
cmake -S gtsam-4.2 -B gtsam-4.2/build \
  -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF \
  -DGTSAM_BUILD_TESTS=OFF \
  -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF \
  -DGTSAM_USE_SYSTEM_EIGEN=ON \
  -DGTSAM_WITH_EIGEN_MKL=OFF

cmake --build gtsam-4.2/build -- -j$(nproc)
sudo cmake --build gtsam-4.2/build --target install
rm -rf gtsam-4.2
```

#### Install OpenCV
[OpenCV] is the world's biggest computer vision library.
During configuration, it will search the computer for other installed libraries that may extend the capabilities of OpenCV.
Thus, we have a fairly long list of dependencies that we will install before compiling OpenCV.

##### Install dependencies
```bash
sudo apt update

# Required
sudo apt install -y build-essential ccache cmake git

# GUI
sudo apt install -y libgtk-3-dev libvtk7-dev

# Media I/O
sudo apt install -y libgdal-dev libjpeg-dev libpng-dev libopenjp2-7-dev libopenexr-dev libtiff-dev libwebp-dev

# Video I/O
sudo apt install -y libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libgphoto2-dev libcanberra-gtk3-module

# Parallel framework
sudo apt install -y libtbb2-dev

# Other third-party libraries
sudo apt install -y libva-dev libeigen3-dev libtesseract-dev
```

##### CUDA support
If you have a computer with a NVIDIA GPU, you can compile OpenCV with CUDA in order to enable GPU processing and `dnn` processing.
Follow the instructions provided by https://developer.nvidia.com/cuda-downloads in order to get CUDA and cuDNN on your computer.
See also the [CUDA installation guide](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/#ubuntu).

##### Compile OpenCV
```bash
# Convenience variable. If variable OpenCV_VERSION is not set, set it to a default value.
tag=${OpenCV_VERSION:-4.9.0}

# Download opencv sources
curl -fSL https://github.com/opencv/opencv/archive/refs/tags/${tag}.tar.gz | tar -zx
curl -fSL https://github.com/opencv/opencv_contrib/archive/refs/tags/${tag}.tar.gz | tar -zx

# Configure OpenCV
cmake -S opencv-${tag} -B opencv-${tag}/build \
-DBUILD_LIST="core,cudev,features2d,imgproc,imgcodecs,highgui,stereo,videoio,viz,xfeatures2d" \
-DCMAKE_BUILD_TYPE=Release \
-DOPENCV_EXTRA_MODULES_PATH="opencv_contrib-${tag}/modules/" \
-DCMAKE_INSTALL_PREFIX="/usr/local" \
-DBUILD_DOCS=OFF \
-DBUILD_EXAMPLES=OFF \
-DBUILD_JAVA=OFF \
-DBUILD_opencv_python2=OFF \
-DBUILD_opencv_python3=OFF \
-DBUILD_PERF_TESTS=OFF \
-DBUILD_TESTS=OFF \
-DCPACK_GENERATOR=DEB \
-DCPACK_MONOLITHIC_INSTALL=ON \
-DOPENCV_ENABLE_NONFREE=ON \
-DOPENCV_GENERATE_PKGCONFIG=ON \
-DOPENCV_IPP_ENABLE_ALL=ON \
-DWITH_GDAL=ON \
-DWITH_GPHOTO2=ON \
-DWITH_GSTREAMER=OFF \
-DWITH_PROTOBUF=ON \
-DBUILD_PROTOBUF=ON \
-DWITH_QT=OFF \
-DWITH_TBB=ON \
-DBUILD_TBB=OFF

# Build OpenCV (be patient)
cmake --build opencv-${tag}/build --config release -- -j $(nproc)

# Install
sudo cmake --build opencv-${tag}/build --target install

# Delete source code and build-artifacts
rm -rf opencv*
```

##### CUDA flags
If you have sucessfully installed CUDA, here are some additional configure options that we have used on the lab computers.

**Note!** You must find [the correct compute capability](https://developer.nvidia.com/cuda-gpus)
for your GPU and replace the value of `CUDA_ARCH_BIN`.

**Note!** Make sure to get the trailing slashes correct if you append it to our previous command!
```bash
-DBUILD_LIST="core,cudev,features2d,imgproc,imgcodecs,highgui,stereo,videoio,viz,xfeatures2d" \
-DWITH_CUDA=ON \
-DWITH_CUBLAS=ON \
-DWITH_CUDNN=ON \
-DCUDA_TOOLKIT_ROOT_DIR="/usr/local/cuda" \
-DCUDA_ARCH_BIN="8.6" \
-DOPENCV_DNN_CUDA=ON
```

### Install CLion
In this course, we are using the CLion [[2]][clion] IDE from JetBrains. Students at UiO can apply for a free Educational License [here [3]][student-license].

Installing CLion from an Ubuntu Terminal is easy [[4]][install-clion]. You can install it as a self-contained snap package, and since snaps update automatically, your CLion installation will always be up to date.

```bash
sudo snap install clion --classic
```
The `--classic` option is required because the CLion snap requires full access to the system, like a traditionally packaged application.

## Setup on other Operating Systems 
As of 2024, tek5030 does not officially support Windows, OS X or other OSs  :'(
Neither are we supporting installations in VirtualBox or other VM's, nor providing pre-configured ISO-files.

If you want to deviate from our Ubuntu 22.04-path,
you should probably be able to solve most labs by installing dependencies via [Homebrew](https://brew.sh/) for Mac or Linux,
but we have not tested it this year.

We highly recommend using the lab computers instead of spending too much time setting up your own computer.


## Automated installation
The scripts in this repo are created to install everything needed, and is tested on Ubuntu 22.04.
You can run all scripts in one go, or choose to run each script separately.

### Run all scripts
```bash
./00-run-complete-setup
```

### Run individual scripts,
For example
```bash
./04-build-opencv
```

---

[How To Add Apt Repository In Ubuntu]: https://linuxize.com/post/how-to-add-apt-repository-in-ubuntu/
[cmake]: https://apt.kitware.com/
[OpenCV]: https://opencv.org/
[clion]: https://www.jetbrains.com/clion/
[student-license]: https://www.jetbrains.com/community/education/#students
[install-clion]: https://www.jetbrains.com/help/clion/installation-guide.html#snap
