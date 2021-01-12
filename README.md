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

In the commands you will often see lines ending with a backslash `\`, like
```bash
some_command \
  more \
  things
```
This is just a line continuation symbol, which is used for clarity and readability, so the example above is equivalent to
```bash
some_command more things
```

## Installation step by step

### Add additional apt repositories
In Ubuntu, we install packages (libraries etc.) using a tool called `apt`. The packages are downloaded from one or more apt software repositories. An APT repository is a network server or a local directory containing deb packages and metadata files that are readable by the APT tools.
While there are thousands of application available in the default Ubuntu repositories, sometimes you may need to install software from a 3rd party repository, for example in order to get a newer version of a library than the "Long Term Support"-version available through the default repositories.

Most repositories are providing a public key to authenticate downloaded packages. The key must also be downloaded and imported.

If you are curious, read more about repositories [on the internet][How To Add Apt Repository In Ubuntu].

#### Add Kitware repository for installation of newer CMake [[1]][cmake]
The CMake version available from the default repository is version 3.10, but as CMake frequently releases important updates and bugfixes, we have nothing to lose and much to win by installing a newer version. The easiest way to do this is to add their APT repository and install from there.

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
we will install a few basic tools before proceeding with installation of the dependencies. The `-y` (or `--yes`) means that we don't want to be propmpted for whether we _really_ want to install or not.

```bash
sudo apt install -y \
  build-essential \
  cmake \
  curl \
  git \
  wget
```

#### Install Eigen
We can install a sufficient version of Eigen with `apt`. In addition, we install blas and lapack.
```bash
sudo apt install -y \
  libblas-dev \
  liblapack-dev \
  libeigen3-dev
```

#### Install Sophus
Sophus must be installed from source. We use `git` and `cmake` for this. Use `man cmake` or `cmake --help` in order to learn more.
Note that Eigen must be installed before we try to install Sophus.
We specify some options to CMake in order to configure the build according to our needs.  A library may support more or less options, but the three we see below are pretty common for many libraries.

On the second last line, we utilize `cmake` also for compiling the software, using the `--build` flag. (In Ubuntu, it is usually the same as using `make`, so you can assume that `cmake --build .` is equal to `make`. Anyhow, the actual compiler (like `gcc`, `g++` or `clang` will eventually be called under the hood, but that is another story).

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

#### Install GeographicLib
We are alo installing GeographicLib from source, but instead of cloning via `git` we are downloading the source code using `curl`.
Using the pipe, we are immedately extracting the downloaded `tar.gz` without it hanging around. It will take some time.

```bash
curl -fL# https://sourceforge.net/projects/geographiclib/files/distrib/GeographicLib-1.51.tar.gz \
| tar -zx

cmake -S GeographicLib-1.51 -B GeographicLib-1.51/build -DCMAKE_BUILD_TYPE=Release
# Copy the files to /usr/local/...
sudo cmake --build GeographicLib-1.51/build --config Release --target install
# Delete the downloaded files
sudo rm -rf GeographicLib-1.51
```

#### Install GTSAM
GTSAM has some additional dependencies that we must install before trying to compile it.
```bash
sudo apt install -y \
  libboost-all-dev \
  libtbb2 \
  libtbb-dev
```
Now we can go on.
```bash
git clone --depth 1 https://github.com/borglab/gtsam.git
cmake -S gtsam -B gtsam/build \
  -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF \
  -DGTSAM_BUILD_TESTS=OFF \
  -DGTSAM_WITH_EIGEN_MKL=OFF
cmake --build gtsam/build -- -j$(nproc)
sudo cmake --build gtsam/build --target install
rm -rf gtsam
```

#### Install OpenCV 
##### Install dependencies
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

##### Compile OpenCV
```bash
# Convenience variable
# If variable OpenCV_VERSION is not set, set it to 4.0.1
tag=${OpenCV_VERSION:-4.0.1}

# Download opencv sources
git clone -b ${tag} --depth 1 https://github.com/opencv/opencv.git opencv-${tag}
git clone -b ${tag} --depth 1 https://github.com/opencv/opencv_contrib.git opencv_contrib-${tag}

mkdir opencv-${tag}/build
cd $_  # $_ is a special variable set to last arg of last command.

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

### Install CLion
In this course, we are using the CLion [[2]][clion] IDE from JetBrains. Students at UiO can apply for a free Educational License [here [3]][student-license].

Installing CLion from an Ubuntu Terminal is easy [[4]][install-clion]. You can install it as a self-contained snap package, and since snaps update automatically, your CLion installation will always be up to date.

```bash
sudo snap install clion --classic
```
The `--classic` option is required because the CLion snap requires full access to the system, like a traditionally packaged application.

Now you can start Clion by typing
```bash
clion &   # The ampersand makes the program run in the background, so you can close the Terminal window.
```
or launching it from the Applications menu in the lower right corner of your desktop (the 3x3 dots).

## Setup on other Operating Systems 
Tek5030 does not officially support Windows, OS X or other OSs, but we have provided an Ubuntu image with dependencies already installed, which you can use with VirtualBox. Please seek more information on the course page.

## Automated installation
The scripts in this repo are created to install everything needed, and is tested on Ubuntu 18.04. You can run all scripts in one go, or choose to run each script separately.

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
[clion]: https://www.jetbrains.com/clion/
[student-license]: https://www.jetbrains.com/community/education/#students
[install-clion]: https://www.jetbrains.com/help/clion/installation-guide.html#snap
