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

ENV_inst_path=`pwd`/assets
ENV_release='/opt'
ENV_dist_path=`pwd`/dist

ENV_opencv='opencv-3.2.0.zip'
ENV_opencv_contrib='opencv_contrib.master.tar.gz'



[ ! -d ${ENV_dist_path} ] && mkdir -p ${ENV_dist_path}

stepNo=0
echo_step()
{
    stepNo=$(($stepNo+1))
    message=$1
    echo -e "\033[41;44m===== step ${stepNo}:  ${message} =====\033[0m" 
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
    rm -rf *
    git clone https://github.com/opencv/opencv.git
    git clone https://github.com/opencv/opencv_contrib.git
    cp -r opencv_contrib/ opencv
    cd opencv
    git checkout 3.2.0
    
    cd opencv_contrib
    git checkout 3.2.0
    sed -i s/"WRAP python)"/"WRAP python java)"/g modules/freetype/CMakeLists.txt
    cd -
    #prepare_opencv_files

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
    #mv OpenCV-*-x86_64.sh ${ENV_dist_path}/OpenCV-3.2.0-x86_64_${ENV_OS}.sh
}

build_opencv()
{
    #install_cuda
    #install_cudnn
    #install_jdk
    #source /etc/profile
    #if [ -z $JAVA_HOME ];then 
    #    echo "JAVA_HOME not found.OpenCV JNI depends on JAVA_HOME"
    #    exit 1
    #else
    #    echo "found java in ${JAVA_HOME}"
    #fi
    #install_opencv_build_essential
    make_opencv
}

#install_basic_tools
build_opencv
