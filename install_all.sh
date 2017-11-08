#!/bin/bash
###########################################################
###########################################################
###########################################################
###########################################################
###########################################################
###########################################################
set -x
ENV_inst_path='/tmp'
ENV_USER=awrun
ENV_GROUP=awrun
ENV_log='/preserve'
ENV_data='/data'
ENV_release='/opt'

#ENV_cuda='cuda-repo-ubuntu1404-8-0-local-ga2_8.0.61-1_amd64.deb'
ENV_cuda='cuda-repo-ubuntu1404-8-0-local-ga2_8.0.61-1_amd64-deb'
ENV_cudnn='cudnn-8.0-linux-x64-v5.1.tgz'
ENV_opencv='git clone https://github.com/opencv/opencv.git'
ENV_nginx='nginx-1.12.1.tar.gz'
ENV_nginx_rtmp='nginx-rtmp-module-master.zip'
ENV_mysql='mysql-apt-config_0.8.8-1_all.deb'


echo "===== step 0 install basic tools for installation"
apt-get update
apt-get install -y git wget curl unzip


echo "=====  step 1 create all needed folders ====="
if [ ! -d $ENV_data ]; then

    echo "no data folder, create data and sub-folders"
    mkdir -p /data/images/uploaded
    mkdir -p /data/images/camera
    mkdir -p /data/images/captioned
    mkdir -p /data/images/detected
    mkdir -p /data/videos/camera
    mkdir -p /data/videos/uploaded
    mkdir -p /data/videos/captioned
    mkdir -p /data/videos/searched
    mkdir -p /data/models
    mkdir -p /data/sw
fi
if [ ! -d $ENV_log ]; then
    echo "no preserve, create a new one"
    mkdir -p /preserve
fi


echo "===== check all package are avaliable in folder"

#echo "AAAAAA======"
#echo $ENV_inst_path/$ENV_cuda

if [ ! -f $ENV_inst_path/$ENV_cuda ];then
    #wget -p $ENV_inst_path https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1404-8-0-local-ga2_8.0.61-1_amd64-deb
    wget  https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1404-8-0-local-ga2_8.0.61-1_amd64-deb
fi

if [ ! -f $ENV_inst_path/$ENV_cudnn ];then
    echo "cudnn not found "
    exit 1
fi

if [ ! -f $ENV_inst_path/$ENV_nginx ];then
    echo "nginx install package not found"
    exit 1
fi

if [ ! -f $ENV_inst_path/$ENV_nginx_rtmp ];then
    echo "nginx rtmp plugin needed"
    exit 1
fi

if [ ! -f $ENV_inst_path/$ENV_mysql ];then
    echo "download mysql dev"
    wget -p $ENV_inst_path http://dev.mysql.com/get/mysql-apt-config_0.8.8-1_all.deb

fi

echo "===== step 1 install cuda ====="
dpkg -i $ENV_inst_path/$ENV_cuda
apt-get update
apt-get install -y cuda
#cp cuda.sh /etc/profile.d/.
touch /etc/profile.d/cuda.sh
echo "export PATH=/usr/local/cuda-8.0/bin${PATH:+:${PATH}}" >> /etc/profile.d/cuda.sh
echo "export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" >> /etc/profile.d/cuda.sh

chmod a+x /etc/profile.d/cuda.sh
source /etc/profile.d/cuda.sh


echo "===== step 2 install cudnn ====="
cp $ENV_inst_path/$ENV_cudnn $ENV_release
tar -xvf /opt/$ENV_cudnn -C $ENV_release
cp -P /opt/cuda/include/cudnn.h /usr/include/
cp -P /opt/cuda/lib64/libcudnn* /usr/lib/x86_64-linux-gnu/.
chmod a+r /usr/lib/x86_64-linux-gnu/libcudnn*


echo "===== step 3 install opencv 3.2"

sudo apt-get update
sudo apt-get install -y build-essential
sudo apt-get install -y cmake
sudo apt-get install -y libgtk2.0-dev
sudo apt-get install -y pkg-config
sudo apt-get install -y python-numpy python-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
sudo apt-get install -y libjpeg-dev libpng-dev libtiff-dev libjasper-dev

apt-get -qq install libopencv-dev build-essential checkinstall cmake pkg-config yasm libjpeg-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev python-dev python-numpy libtbb-dev qt5-default qtbase5-dev qtcore5-dev qtdeclarative5-dev libgtk2.0-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils

apt-get -y install  libdc1394-22  libpng12-dev  libqt4-dev libfaac-dev




cd /opt
git clone https://github.com/opencv/opencv.git
#git clone https://github.com/opencv/opencv_contrib.git
cd opencv
git checkout 3.2.0

mkdir build
cd build
cmake -G "Unix Makefiles" -D CMAKE_CXX_COMPILER=/usr/bin/g++ CMAKE_C_COMPILER=/usr/bin/gcc -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D WITH_FFMPEG=ON -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D BUILD_EXAMPLES=ON -D WITH_QT=ON -D WITH_OPENGL=ON -D BUILD_FAT_JAVA_LIB=ON -D INSTALL_TO_MANGLED_PATHS=ON -D INSTALL_CREATE_DISTRIB=ON -D INSTALL_TESTS=ON -D ENABLE_FAST_MATH=ON -D WITH_IMAGEIO=ON -D BUILD_SHARED_LIBS=OFF -D WITH_GSTREAMER=ON -D WITH_CUDA=OFF ..






make -j$(nproc)

make install

sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf'

ldconfig


echo "===== step 4 install tensorflow ====="

apt-get install -y libcupti-dev

apt-get install -y python-pip python-dev python-virtualenv

virtualenv --system-site-packages /virenv


source /virenv/bin/activate

easy_install -U pip

pip install --upgrade tensorflow

#pip install --upgrade tensorflow-gpu


source /virenv/bin/activate

deactivate

echo "===== step 5 install nginx ====="
apt-get install -y libssl-dev

tar -xvf $ENV_inst_path/$ENV_nginx -C $ENV_inst_path

mv $ENV_inst_path/$ENV_nginx_rtmp $ENV_inst_path/nginx-1.12.1/


cd $ENV_inst_path/nginx-1.12.1
unzip nginx-rtmp-module-master.zip

./configure --prefix=/usr/local/nginx --add-module=$ENV_inst_path/nginx-1.12.1/nginx-rtmp-module-master --with-http_ssl_module
make
make install
cd ..
#cp nginx.conf /etc/init/
#initctl reload-configuration



echo "===== step 6 install mysql ====="

export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mysql-server mysql-server/root_password password AwakeData!" | debconf-set-selections
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password AwakeData!" | debconf-set-selections
dpkg -i $ENV_inst_path/mysql-apt-config_0.8.8-1_all.deb
apt-get update
apt-get install -y mysql-server

echo "===== step 7 install jdk ====="
add-apt-repository -y ppa:webupd8team/java
apt-get update
debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections

apt-get -y install oracle-java8-installer 




echo "===== step 9 copy all models to /data/models"

#cp models/*.pb /data/modles/.

echo "===== step 10 create front end folders ====="

mkdir -p /usr/share/nginx/html
#cp nginx_conf/nginx.conf /usr/local/nginx/conf/.

echo "===== step 11 copy dist and server to target path"

#unzip server-1.0-SNAPSHOT.zip

#tar -xvf dist.tar.gz -C /usr/share/nginx/html/.

echo "===== step 12 instll release ====="
create_user()
{
        getent group $ENV_GROUP >/dev/null || groupadd -g 1007 -r $ENV_GROUP
        getent passwd $ENV_USER >/dev/null || useradd -r -u 1007 -g $ENV_USER -s /sbin/nologin -d /opt/server -c "$ENV_USER" $ENV_USER

}

release_installation()
{
        current_user=$(cat /etc/passwd | grep $ENV_USER)
        if [  -z "$current_user" ]; then
                 echo "create user for release"
                 create_user
        elif [ ! -z "$current_user" ];then
                echo "user already exist"
        else
                echo "pass"
        fi

}

release_installation




