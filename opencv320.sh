#!/bin/bash
###########################################################
##############   copy right awakedata   ###################
##############   Author Eric Wang       ###################
###########################################################
###########################################################
###########################################################

set -e

ENV_OS=$(lsb_release -r -s)

if [ $ENV_OS == '14.04' ];then
    echo "version is correct 14"
elif [ $ENV_OS == '16.04' ]; then
    echo "version is correct 16"
else
    exit 1
fi

ENV_JDK_8u151="jdk-8u151-linux-x64.tar.gz"
ENV_inst_path=`pwd`/assets
ENV_release='/opt'
ENV_dist_path=`pwd`/dist
ENV_cuda="cuda-repo-ubuntu_${ENV_OS}-8-0-local-ga2_8.0.61-1_amd64.deb"
ENV_cudnn5='cudnn-8.0-linux-x64-v5.1.tgz'
ENV_cudnn="libcudnn6_6.0.21-1+cuda8.0_amd64_${ENV_OS}.deb"
ENV_opencv='opencv-3.2.0.zip'
ENV_opencv_contrib='opencv_contrib.master.tar.gz'
ENV_tensorflow='tensorflow-1.4.1.zip'

# URLS
URL_CUDA_UBUNTU14="https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1404-8-0-local-ga2_8.0.61-1_amd64-deb"
URL_CUDA_UBUNTU16="https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb"
URL_CUDNN_UBUNTU14="https://developer.nvidia.com/compute/machine-learning/cudnn/secure/v6/prod/8.0_20170307/Ubuntu14_04_x64/libcudnn6_6.0.21-1+cuda8.0_amd64-deb"
URL_CUDNN_UBUNTU16="https://developer.nvidia.com/compute/machine-learning/cudnn/secure/v6/prod/8.0_20170307/Ubuntu16_04_x64/libcudnn6_6.0.21-1+cuda8.0_amd64-deb"
URL_TENSORFLOW="https://github.com/tensorflow/tensorflow/archive/v1.4.1.zip"

[ ! -d ${ENV_dist_path} ] && mkdir -p ${ENV_dist_path}

stepNo=0
echo_step()
{
    stepNo=$(($stepNo+1))
    message=$1
    echo -e "\033[41;44m===== step ${stepNo}:  ${message} =====\033[0m" 
}

install_basic_tools()
{
    echo_step "install basic tools for installation"
    apt-get update
    apt-get install -y git wget curl unzip openssh-server vim htop
}

install_cuda()
{    
    echo_step "install cuda"
    if [ ! -f $ENV_inst_path/$ENV_cuda ];then
        cd $ENV_inst_path
        rm cuda-repo-ubuntu1404-8-0-local-ga2_8.0.61-1_amd64-deb* | true
        if [ $ENV_OS == '14.04' ];then
            wget URL_CUDA_UBUNTU14 -O $ENV_cuda
        elif [ $ENV_OS == '16.04' ]; then
            wget URL_CUDA_UBUNTU16 -O $ENV_cuda
        else
            exit 1
        fi            
        cd -
    fi
    dpkg -i $ENV_inst_path/$ENV_cuda
    apt-get update
    apt-get install -y cuda
    echo "" > /etc/profile.d/cuda.sh
    echo 'export PATH=/usr/local/cuda-8.0/bin:${PATH}' >> /etc/profile.d/cuda.sh
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64:${LD_LIBRARY_PATH}' >> /etc/profile.d/cuda.sh

    chmod a+x /etc/profile.d/cuda.sh
    source /etc/profile.d/cuda.sh
}

install_cudnn()
{
    echo_step "install cudnn"

    echo "install cudnn 5"

    if [ ! -f $ENV_inst_path/$ENV_cudnn5 ];then
        echo "cudnn5 ${ENV_cudnn5} needed"
        exit 1
    fi

    cp $ENV_inst_path/$ENV_cudnn5 $ENV_release
    tar -xvf /opt/$ENV_cudnn5 -C $ENV_release
    cp -P /opt/cuda/include/cudnn.h /usr/include/
    cp -P /opt/cuda/lib64/libcudnn* /usr/lib/x86_64-linux-gnu/.
    chmod a+r /usr/lib/x86_64-linux-gnu/libcudnn*

    echo "install cudnn 6"
    if [ ! -f $ENV_inst_path/$ENV_cudnn ];then
        cd $ENV_inst_path
        if [ $ENV_OS == '14.04' ];then
            wget $URL_CUDNN_UBUNTU14 -O $ENV_cudnn
        elif [ $ENV_OS == '16.04' ]; then
            wget $URL_CUDNN_UBUNTU16 -O $ENV_cudnn
        else
            exit 1
        fi        
        cd -
    fi
    dpkg -i $ENV_inst_path/$ENV_cudnn
}

install_jdk()
{
    echo_step "install jdk"

    if [ ! -d "/usr/lib/jvm" ];then
        echo "create jvm folder for jdk"
        mkdir /usr/lib/jvm
    elif [ -d "/usr/lib/jvm" ];then
        echo "delete all old jdk which are under jvm folder"
        rm -rf /usr/lib/jvm
        mkdir /user/lib/jvm
    fi
    
    if
    [  -f $ENV_inst_path/$ENV_JDK_8u151 ];then
        tar -xvf $ENV_inst_path/$ENV_JDK_8u151 -C /usr/lib/jvm
    fi
    
    # set java environment var
    rm -f /etc/profile.d/jdk.sh
    echo "export J2SDKDIR=/usr/lib/jvm/jdk1.8.0_151" > /etc/profile.d/jdk.sh
    echo "export J2REDIR=/usr/lib/jvm/jdk1.8.0_151/jre" >> /etc/profile.d/jdk.sh
    echo "export PATH=$PATH:/usr/lib/jvm/jdk1.8.0_151/bin:/usr/lib/jvm/jdk1.8.0_151/db/bin:/usr/lib/jvm/jdk1.8.0_151/jre/bin" >> /etc/profile.d/jdk.sh
    echo "export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_151" >> /etc/profile.d/jdk.sh
    echo "export DERBY_HOME=/usr/lib/jvm/jdk1.8.0_151/db" >> /etc/profile.d/jdk.sh
    chmod a+x /etc/profile.d/jdk.sh
    source /etc/profile.d/jdk.sh
    # set jdk alternatives
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.8.0_151/bin/java 100
    update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.8.0_151/bin/javac 100
}

install_opencv_build_essential()
{
    echo_step "install opencv build essential"
    apt-get update
    apt-get install -y build-essential
    apt-get install -y cmake ant
    apt-get install -y libgtk2.0-dev
    apt-get install -y pkg-config
    apt-get install -y python-numpy python-dev
    apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
    apt-get install -y libjpeg-dev libpng-dev libtiff-dev libjasper-dev
    if [ $ENV_OS == '14.04' ];then
        apt-get install -y libxine-dev libhdf5-7 libhdf5-dev
    elif [ $ENV_OS == '16.04' ]; then
        apt-get install -y libxine2-dev libhdf5-10 libhdf5-dev
    fi
    apt-get -qq install libopencv-dev build-essential checkinstall cmake pkg-config \
                        yasm libjpeg-dev libjasper-dev libavcodec-dev libavformat-dev \
                        libswscale-dev libdc1394-22-dev \
                        libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev \
                        libv4l-dev python-dev python-numpy libtbb-dev libgtk2.0-dev libmp3lame-dev \
                        libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev \
                        libxvidcore-dev x264 v4l-utils libtesseract-dev libopenblas-dev liblapacke-dev \
                        libavresample-dev libleptonica-dev libgphoto2-dev libprotobuf-dev
    apt-get -y install libdc1394-22 libpng12-dev  libqt4-dev libfaac-dev
}

prepare_opencv_files()
{
    ENV_ippicv='ippicv_linux_20151201.tgz'
    ENV_protobuf='protobuf-cpp-3.1.0.tar.gz'
    ENV_tinydnn='v1.0.0a3.tar.gz'

    echo_step "prepare opencv download files"
    if [ -f $ENV_inst_path/$ENV_ippicv ]; then
        echo "prepare ippicv"
        ipp_file=$ENV_inst_path/$ENV_ippicv
        ipp_hash=$(md5sum $ipp_file | cut -d" " -f1)
        ipp_dir=3rdparty/ippicv/downloads/linux-$ipp_hash
        mkdir -p $ipp_dir
        cp $ipp_file $ipp_dir
    fi

    if [ -f $ENV_inst_path/$ENV_protobuf ]; then
        echo "prepare protobuf"
        protobuf_file=$ENV_inst_path/$ENV_protobuf
        protobuf_hash=$(md5sum $protobuf_file | cut -d" " -f1)
        protobuf_dir=opencv_contrib/modules/dnn/.download/$protobuf_hash/v3.1.0
        mkdir -p $protobuf_dir
        cp $protobuf_file $protobuf_dir
    fi
    
    if [ -f $ENV_inst_path/$ENV_tinydnn ]; then
        echo "prepare tinydnn"
        tinydnn_file=$ENV_inst_path/$ENV_tinydnn
        tinydnn_hash=$(md5sum $tinydnn_file | cut -d" " -f1)
        tinydnn_dir=3rdparty/tinydnn/downloads/$tinydnn_hash
        mkdir -p $tinydnn_dir
        cp $tinydnn_file $tinydnn_dir
    fi
}

make_opencv()
{
    echo_step "make opencv 3.2"
    source /etc/profile.d/jdk.sh
    
    #cd /opt
    if [ ! -d opencv ]; then
        if [ -f $ENV_inst_path/$ENV_opencv ]; then
            unzip $ENV_inst_path/$ENV_opencv
        else
            git clone https://github.com/opencv/opencv.git
        fi
    fi

    if [ ! -d opencv_contrib ]; then
        if [ -f $ENV_inst_path/$ENV_opencv_contrib ]; then
            tar xvf $ENV_inst_path/$ENV_opencv_contrib -C /opt/opencv
        else
            git clone https://github.com/opencv/opencv_contrib.git
        fi
    fi
    mv opencv_contrib/ opencv
    cd opencv
    git checkout 3.2.0
    cd opencv_contrib
    git checkout 3.2.0
    sed -i s/"WRAP python)"/"WRAP python java)"/g modules/freetype/CMakeLists.txt
    cd -
    prepare_opencv_files

    rm build -rf && mkdir build
    cd build
    echo_step "create Make files"
    cmake -G "Unix Makefiles" \
          -D CMAKE_CXX_COMPILER=/usr/bin/g++ CMAKE_C_COMPILER=/usr/bin/gcc \
          -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D WITH_FFMPEG=ON \
          -D WITH_QT=ON -D WITH_OPENGL=ON -D BUILD_FAT_JAVA_LIB=ON -D INSTALL_TO_MANGLED_PATHS=ON \
          -D WITH_IMAGEIO=ON -D WITH_GSTREAMER=ON -D WITH_CUDA=ON \
          -D BUILD_SHARED_LIBS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D BUILD_DOCS=OFF \
          -D INSTALL_C_EXAMPLES=OFF -D INSTALL_PYTHON_EXAMPLES=OFF -D BUILD_EXAMPLES=OFF \
          -D INSTALL_CREATE_DISTRIB=ON -D INSTALL_TESTS=OFF -D ENABLE_FAST_MATH=OFF \
          -D ENABLE_SSE3=ON -D ENABLE_SSSE3=ON -D ENABLE_SSE41=ON -D ENABLE_SSE42=ON \
          -D ENABLE_AVX=ON -D ENABLE_AVX2=ON -D ENABLE_FMA3=ON \
          -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
          ..

    echo_step "make opencv"
    make -j$(nproc)
    echo_step "make package"
    make package
    mv OpenCV-*-x86_64.sh ${ENV_dist_path}/OpenCV-3.2.0-x86_64_${ENV_OS}.sh
}

build_opencv()
{
    install_cuda
    install_cudnn
    install_jdk
    install_opencv_build_essential
    make_opencv
}

build_tensorflow()
{
    source /etc/profile.d/jdk.sh
    if [ ! -f $ENV_inst_path/$ENV_tensorflow ];then
        cd $ENV_inst_path
        wget $URL_TENSORFLOW -O $ENV_tensorflow 
        cd -
    fi
    echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" > /etc/apt/sources.list.d/bazel.list
    curl https://bazel.build/bazel-release.pub.gpg | apt-key add -  
    apt-get update 
    apt-get -f install bazel  
    apt-get install python-numpy python-dev python-pip python-wheel

    unzip $ENV_inst_path/$ENV_tensorflow
    mv ./tensorflow-1.4.1 /opt/.
    cd /opt/tensorflow-1.4.1
    ./configure #需要处理弹出选择python路径,python library路径
    bazel build -c opt --copt=-msse3 --copt=-msse4.1 --copt=-msse4.2 --copt=-mavx --copt=-mavx2 --copt=-mfma //tensorflow/tools/pip_package:build_pip_package
    bazel-bin/tensorflow/tools/pip_package:build_pip_package $ENV_dist_path
}

install_jdk
install_basic_tools
install_cuda
install_cudnn
install_opencv_build_essential



#make_opencv
