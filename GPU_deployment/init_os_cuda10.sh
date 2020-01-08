#!/bin/bash
###########################################################
##############   Author Eric Wang       ###################
###########################################################
####### script is dedicate for product installation #######
###########################################################

set -e
ENV_log_name="/opt/inst_log_"$(date +%Y_%m-%d_%H-%M-%S)
ENV_remote_url=$(whiptail --inputbox "Edit Url If Needed" 8 78 http://origin.yuananzhineng.com:8000/ --title "URL info" 3>&1 1>&2 2>&3)
ENV_OS=$(lsb_release -r -s)
ENV_inst_path=`pwd`/assets
ENV_release='/opt'
ENV_JDK_8u151="jdk-8u151-linux-x64.tar.gz"
ENV_opencv="OpenCV-3.2.0-x86_64_${ENV_OS}.sh"
ENV_nginx="nginx-1.12.1.tar.gz"
ENV_nginx_rtmp="nginx-rtmp-module-master.zip"
ENV_nginx_log="nginx"
ENV_teamviewer="teamviewer_14.0.14470_amd64.deb"
ENV_monitorix="monitorix_3.10.1-izzy1_all.deb"
ENV_darner="darner"
ENV_ffmpeg="ffmpeg"
ENV_net_driver="e1000e.ko"
ENV_kernel=(
    "linux-headers-4.14.16-041416_4.14.16-041416.201801310931_all.deb"
    "linux-headers-4.14.16-041416-generic_4.14.16-041416.201801310931_amd64.deb"
    "linux-image-4.14.16-041416-generic_4.14.16-041416.201801310931_amd64.deb"
)
ENV_mount_point="/mount"
ENV_kafka="kafka_2.11-2.0.0.tgz"
ENV_camera="get_camera_id.py"
ENV_darner_conn="check_darner.sh"
################### cuda 10 suite ###################
ENV_nvidia_driver="NVIDIA-Linux-x86_64-410.93.run "
ENV_cuda_10="cuda-repo-ubuntu1604-10-0-local-10.0.130-410.48_1.0-1_amd64.deb"
ENV_cudnn_75="cudnn-10.0-linux-x64-v7.5.0.56.tgz"
ENV_tensorRT='nv-tensorrt-repo-ubuntu1604-cuda10.0-trt5.1.5.0-ga-20190427_1-1_amd64.deb'
ENV_tensor_native=(
    "libtensorflow_framework.so.1.14.1"
    "libtensorflow_jni.so"
    "libtftrt.so"
)
# URLS
URL_JDK=$ENV_remote_url$ENV_JDK_8u151
URL_OPENCV=$ENV_remote_url$ENV_opencv
URL_NVIDIA_DRIVER=$ENV_remote_url$ENV_nvidia_driver
URL_NGINX=$ENV_remote_url$ENV_nginx
URL_NGINX_RTMP=$ENV_remote_url$ENV_nginx_rtmp
URL_NGINX_LOG=$ENV_remote_url$ENV_nginx_log
URL_DARNER=$ENV_remote_url$ENV_darner
URL_FFMPEG=$ENV_remote_url$ENV_ffmpeg
URL_CAMERA=$ENV_remote_url$ENV_camera
URL_DARNER_CONN=$ENV_remote_url$ENV_darner_conn
URL_TEAMVIEWER=$ENV_remote_url$ENV_teamviewer
URL_CUDA_UBUNTU16_10=$ENV_remote_url$ENV_cuda_10
URL_CUDNN_UBUNTU16_75=$ENV_remote_url$ENV_cudnn_75
URL_TENSORRT=$ENV_remote_url$ENV_tensorRT

generic_steps_1=(
    install_basic_tools
    install_jdk
    install_nginx
    )

generic_steps_2=(
    update_kernel
    disable_update
    )
optional_steps_1=(
    install_darner
    install_cuda
    install_cudnn
    install_opencv
    )
optional_steps_2=(
    update_ffmpeg
    make_partition
    set_mysql_backup
    install_watchdog
    install_teamviewer_64bit
    )
stepNo=0
function echo_step()
{
    stepNo=$(($stepNo+1))
    message=$1
    echo -e "\033[41;44m===== step ${stepNo}:  ${message} =====\033[0m" 
}
#################################################################################
################################  UI whiptail part ##############################
#################################################################################

function ui_summary_menu(){

if [ $ENV_OS == "16.04" ] || [ $ENV_OS == "18.04" ];then


    #if [ -d "$ENV_inst_path" ];then

        summary=$(whiptail --title "Select Newly Install or Repair" \
        --backtitle "UP/DOWN change curser, SPACE select items, ENTER to confirm" \
        --clear --menu --noitem "Select Options" 15 50 5 \
    	"newly_install" "totally new system need to be installed" \
    	"system_repair" "recover lost dependencies" \
    	3>&1 1>&2 2>&3)

    #else
        #whiptail --title "No Assets Found" --msgbox "No Assets folder found, installation is terminated" 8 78
        #exit 1
     #   mkdir assets
    #fi
else
    whiptail --title "Current OS version is wrong" \
    --msgbox " Current Linux Incorrect ($ENV_OS)\n Need Ubuntu 16.04
    " 8 78
    exit 1
fi

}



function ui_main_menu(){

option=$(whiptail --title "Select Type of APP"  --clear --menu "Select Options" 15 60 7 \
    "1" "gpu-server" \
    "2" "no-gpu-server" \
    3>&1 1>&2 2>&3)

case "$option" in
        "1")
            deb_file=skyeye.gpu-server*.deb
            data_folder=/data/server
            product_branch="server"
            ;;
        "2")
            deb_file=skyeye.edge*.deb
            data_folder=/data/edge
            product_branch="edge"
            ;;
        *)
esac

}

function ui_select_module(){

module=$(whiptail --title "Select more option" --checklist --separate-output --noitem "module" 25 83 10 \
	"deploy_deb" OFF \
    "make_partition" OFF \
    "update_ffmpeg" OFF \
    "install_mysql" ON \
    "init_database" ON \
	"set_mysql_backup" OFF \
	"install_watchdog" OFF \
    "install_teamviewer_64bit" OFF \
    "install_zabbix_agent" OFF \
    "disable_update" ON \
	3>&1 1>&2 2>&3)
enable_deb=$(echo $module | awk '{ print $1 }')

}




function ui_set_zabbix_agnet(){

zabbix_ip=$(whiptail --inputbox "Input zabbix server ip or domain" 8 78 monitor.yuananzhineng.com \
    --title "Zabbix Server selection" 3>&1 1>&2 2>&3)
zabbix_hostname=$(whiptail --inputbox "Input hostname for this agent" 8 78  \
    --title "Zabbix Agent Hostname" 3>&1 1>&2 2>&3)

if [ ! -z $zabbix_ip ] && [ ! -z $zabbix_hostname ];then
    echo "next step"
else
    ui_set_zabbix_agnet
fi

}


function ui_select_deb(){

cd $ENV_inst_path
file_list=$(ls $deb_file -lhp  | awk -F ' ' ' { print $9 " " $5 } ')

if [ -d models ];then
cd models
model_files=$(ls *.pb -lhp  | awk -F ' ' ' { print $9 " " $5 } ')
cd ..
fi

################# select deb file ######################
if [ -z "$file_list" ]; then
    whiptail --title "no deb found" --msgbox "No deb file found, installation cannelled" 8 78
    exit 1
else
    show_deb=$(whiptail --title "deb list" --radiolist  --separate-output \
    --noitem "please select the file to install" 20 50 6  $file_list \
    3>&1 1>&2 2>&3)

    if [ -z "$show_deb" ];then
        whiptail --title "test" --msgbox "No file is selected, go back" 8 78
        show_deb=$(whiptail --title "deb list" --radiolist  --separate-output \
        --noitem "please select the file to install" 20 50 6  $file_list \
        3>&1 1>&2 2>&3)
    fi
fi

################# select model files ####################
if [ $option == "1" ] || [ $option == "3" ];then
    if [ -z "$model_files" ];then
        whiptail --title "model error" --msgbox "No model file found, installation cannelled" 8 78
    else
        show_models=$(whiptail --title "model list" --checklist  --separate-output \
        --noitem "please select models" 30 50 20  $model_files \
        3>&1 1>&2 2>&3)
    fi
fi

}

function ui_hardware_module(){

hardware_module=$(whiptail --title "Select GPU driver option" --backtitle "disable nouveau is for disable integrated VGA on motherboard" \
    --checklist --separate-output --noitem "select GPU driver" 20 78 5 \
    "disable_nouveau" OFF \
    "install_display_driver" ON \
    3>&1 1>&2 2>&3)

}

function ui_get_disk(){
ENV_DISK_NAME=$(whiptail --inputbox "Input device name of secondary drive" 8 78 sdb \
    --title "Storage Device Selection" 3>&1 1>&2 2>&3)

if [ ! -z $ENV_DISK_NAME ];then
    make_partition
else
    ENV_DISK_NAME=$(whiptail --inputbox "nothing input, please input an avaliable device name" 8 78 sdb \
    --title "Storage Device Selection" 3>&1 1>&2 2>&3)
fi

}

function ui_repair_list(){

repair_list=$(whiptail --title "Select one or more module" --checklist --separate-output --noitem "module" 50 78 30 \
    "install_basic_tools" OFF \
    "install_jdk" OFF \
    "install_mysql" OFF \
    "disable_nouveau" OFF \
    "install_cuda" OFF \
    "install_display_driver" OFF \
    "update_nvidia_driver" OFF \
    "update_tensor_RT_lib" OFF \
    "install_cudnn" OFF \
    "install_opencv" OFF \
    "install_nginx" OFF \
    "install_nginx_rtmp" OFF \
    "init_database" OFF \
    "install_darner" OFF \
    "update_ffmpeg" OFF \
    "install_kafka" OFF \
    "make_partition" OFF \
    "set_mysql_backup" OFF \
    "install_watchdog" OFF \
    "install_teamviewer_64bit" OFF \
    "install_zabbix_agent" OFF \
    "install_sensors" OFF \
    "update_kernel" OFF \
    "install_net_driver" OFF \
    "disable_update" OFF \
    "system_init_report" OFF \
    3>&1 1>&2 2>&3)

}

#################################################################################
################################  generic steps    ##############################
#################################################################################

function install_basic_tools()
{
    echo_step "install basic tools for installation"
    apt-get update
    apt-get install -y wget unzip openssh-server vim htop gdisk build-essential ffmpeg
    #export LC_ALL=en_US.UTF-8
    #locale-gen en_US.UTF-8
    timedatectl set-timezone Etc/UTC
}

function install_jdk()
{
    echo_step "install jdk"
    if [ ! -d "/usr/lib/jvm" ];then
        echo "create jvm folder for jdk"
        mkdir /usr/lib/jvm
    elif [ -d "/usr/lib/jvm" ];then
        echo "delete all old jdk which are under jvm folder"
        rm -rf /usr/lib/jvm
        mkdir /usr/lib/jvm
    fi
    
    if
    [  ! -f $ENV_inst_path/$ENV_JDK_8u151 ];then
        wget $URL_JDK -P $ENV_inst_path
    fi

    tar -xvf $ENV_inst_path/$ENV_JDK_8u151 -C /usr/lib/jvm
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
    # add model encrypt jar to jre
    cp /usr/lib/jvm/jdk1.8.0_151/jre/lib/security/policy/unlimited/local_policy.jar /usr/lib/jvm/jdk1.8.0_151/jre/lib/security/
    cp /usr/lib/jvm/jdk1.8.0_151/jre/lib/security/policy/unlimited/US_export_policy.jar /usr/lib/jvm/jdk1.8.0_151/jre/lib/security/
    chown uucp:143 /usr/lib/jvm/jdk1.8.0_151/jre/lib/security/*.jar
}

function install_nginx()
{
    echo_step "install nginx 1.12"
    apt-get install -y libssl-dev libpcre3-dev
    rm $ENV_inst_path/nginx-1.12.1 -rf | true

    if [ ! -f $ENV_inst_path/$ENV_nginx ];then
        wget $URL_NGINX -P $ENV_inst_path
    fi

    tar -xvf $ENV_inst_path/$ENV_nginx -C $ENV_inst_path
    cd $ENV_inst_path/nginx-1.12.1
    ./configure --prefix=/usr/local/nginx  --with-http_ssl_module
    make
    make install

    echo -e "[Unit]\nDescription=The NGINX HTTP and reverse proxy server\nAfter=syslog.target network.target remote-fs.target nss-lookup.target" > /lib/systemd/system/nginx.service
    echo -e "[Service]\nType=forking\nPIDFile=/usr/local/nginx/logs/nginx.pid\nExecStartPre=/usr/local/nginx/sbin/nginx -t\nExecStart=/usr/local/nginx/sbin/nginx\nPrivateTmp=true\nUser=root\nGroup=root" >> /lib/systemd/system/nginx.service
    echo -e "[Install]\nWantedBy=multi-user.target" >> /lib/systemd/system/nginx.service
    #cp $ENV_inst_path/nginx.service /lib/systemd/system/.
    systemctl daemon-reload
    systemctl start nginx
    systemctl enable nginx
    #set access log rotation
    if [ ! -f $ENV_inst_path/$ENV_nginx_log ];then
        wget $URL_NGINX_LOG -P $ENV_inst_path
    fi
    cp $ENV_inst_path/$ENV_nginx_log /etc/logrotate.d/.
    logrotate -f /etc/logrotate.d/nginx


}


function install_nginx_rtmp()
{
    echo_step "install nginx 1.12 + rtmp plugin"
    apt-get install -y libssl-dev libpcre3-dev
    rm $ENV_inst_path/nginx-1.12.1 -rf | true

    if [ ! -f $ENV_inst_path/$ENV_nginx ];then
        wget $URL_NGINX -P $ENV_inst_path
    fi
    if [ ! -f $ENV_inst_path/$ENV_nginx_rtmp ];then
        wget $URL_NGINX_RTMP -P $ENV_inst_path
    fi


    tar -xvf $ENV_inst_path/$ENV_nginx -C $ENV_inst_path
    cp $ENV_inst_path/$ENV_nginx_rtmp $ENV_inst_path/nginx-1.12.1/
    cd $ENV_inst_path/nginx-1.12.1
    unzip $ENV_nginx_rtmp
    ./configure --prefix=/usr/local/nginx --add-module=$ENV_inst_path/nginx-1.12.1/nginx-rtmp-module-master --with-http_ssl_module
    make
    make install
    cd ..
    echo -e "[Unit]\nDescription=The NGINX HTTP and reverse proxy server\nAfter=syslog.target network.target remote-fs.target nss-lookup.target" > /lib/systemd/system/nginx.service
    echo -e "[Service]\nType=forking\nPIDFile=/usr/local/nginx/logs/nginx.pid\nExecStartPre=/usr/local/nginx/sbin/nginx -t\nExecStart=/usr/local/nginx/sbin/nginx\nPrivateTmp=true\nUser=root\nGroup=root" >> /lib/systemd/system/nginx.service
    echo -e "[Install]\nWantedBy=multi-user.target" >> /lib/systemd/system/nginx.service
    #cp $ENV_inst_path/nginx.service /lib/systemd/system/.
    systemctl daemon-reload
    systemctl start nginx
    systemctl enable nginx
    #set access log rotation
    if [ ! -f $ENV_inst_path/$ENV_nginx_log ];then
        wget $URL_NGINX_LOG -P $ENV_inst_path
    fi
    cp $ENV_inst_path/$ENV_nginx_log /etc/logrotate.d/.
    logrotate -f /etc/logrotate.d/nginx


}

function install_mysql()
{
    echo_step "install mysql 5.7"
    export DEBIAN_FRONTEND="noninteractive"
    debconf-set-selections <<< "mysql-server mysql-server/root_password password password!" | debconf-set-selections | true
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password password!" | debconf-set-selections | true
    apt-get install -y mysql-server

}

function init_database()
{

 mysql -uroot -ppassword! -e "DROP DATABASE IF EXISTS test_db;
        CREATE DATABASE test_db CHARACTER SET utf8 COLLATE utf8_general_ci;
        DROP USER IF EXISTS 'test_db'@'localhost';
        CREATE USER 'test_db'@'localhost' IDENTIFIED BY 'password!';
        GRANT USAGE ON *.* TO 'test_db'@'localhost';
        GRANT ALL PRIVILEGES ON test_db.* TO 'test_db'@'localhost' WITH GRANT OPTION;"

}

function install_sensors()
{
    apt-get install -y lm-sensors
    echo "UserParameter=cpu_temp,sensors -u | grep \"temp1_input\" | awk '{ print $2 }'" >> /etc/zabbix/zabbix_agentd.conf.d/common.conf

}

function disable_update()
{
    echo "APT::Periodic::Update-Package-Lists \"0\";" > /etc/apt/apt.conf.d/10periodic
    echo "APT::Periodic::Download-Upgradeable-Packages \"0\";" >> /etc/apt/apt.conf.d/10periodic
    echo "APT::Periodic::AutocleanInterval \"0\";" >> /etc/apt/apt.conf.d/10periodic
    echo "APT::Periodic::Unattended-Upgrade \"0\";" >> /etc/apt/apt.conf.d/10periodic
    echo "APT::Periodic::Update-Package-Lists \"0\";" >  /etc/apt/apt.conf.d/20auto-upgrades
    echo "APT::Periodic::Unattended-Upgrade \"0\";" >> /etc/apt/apt.conf.d/20auto-upgrades
    systemctl stop apt-daily.service
    systemctl stop apt-daily.timer
    systemctl stop apt-daily-upgrade.timer
    systemctl mask apt-daily.service
    systemctl mask apt-daily.timer
    systemctl mask apt-daily-upgrade.timer
    systemctl mask apt-daily-upgrade.service
}


function install_kafka()
{
    echo_step "install kafka/zookeeper"
    if [ -f $ENV_inst_path/$ENV_kafka ];then
        wget $URL_KAFKA -P $ENV_inst_path
    fi
    tar -xvf $ENV_inst_path/$ENV_kafka -C /opt/.
    ln -s /opt/kafka_2.11-2.0.0 /opt/kafka
    chmod a+x -R /opt/kafka
    chown -R awrun:awrun /opt/kafka

    ######## systemd of zookeeper #####
    systemd_zookeeper="/lib/systemd/system/zookeeper.service"
    echo -e "[Unit]\nDescription=ZooKeeper Service\nDocumentation=http://zookeeper.apache.org\nRequires=network.target\nAfter=network.target" > $systemd_zookeeper
    echo -e "[Service]\nType=simple\nUser=awrun\nGroup=awrun" >> $systemd_zookeeper
    echo -e "ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties" >> $systemd_zookeeper
    echo -e "ExecStop=/opt/kafka/bin/zookeeper-server-stop.sh" >> $systemd_zookeeper
    echo -e "[Install]\nWantedBy=multi-user.target" >> $systemd_zookeeper

    ######## systemd of kakfa #######
    systemd_kafka="/lib/systemd/system/kafka.service"
    echo -e "[Unit]\nDescription=Kafka Service\nDocumentation=http://kafka.apache.org\nRequires=network.target\nAfter=network.target" > $systemd_kafka
    echo -e "[Service]\nType=simple\nUser=awrun\nGroup=awrun" >> $systemd_kafka
    echo -e "ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties" >> $systemd_kafka
    echo -e "ExecStop=/opt/kafka/bin/kafka-server-stop.sh\nRestart=on-failure" >> $systemd_kafka
    echo -e "[Install]\nWantedBy=multi-user.target" >> $systemd_kafka

    ######## set kafka/zookeeper data location ########
    sed -i "s/dataDir.*/dataDir\=\/data\/zookeeper/g" /opt/kafka/config/zookeeper.properties
    sed -i "s/log.dirs.*/log.dirs\=\/data\/kafka/g" /opt/kafka/config/server.properties

    systemctl daemon-reload
    systemctl start zookeeper
    sleep 5
    systemctl start kafka

}

#################################################################################
################################  server  steps    ##############################
#################################################################################
function install_cuda()
{    
    echo_step "install cuda 10"
    if [ ! -f $ENV_inst_path/$ENV_cuda_10 ];then
        wget $URL_CUDA_UBUNTU16_10 -P $ENV_inst_path
    fi
    dpkg -i $ENV_inst_path/$ENV_cuda_10
    apt-key add /var/cuda-repo-10-0-local-10.0.130-410.48/7fa2af80.pub
    apt-get update
    apt-get install -y cuda
    echo "" > /etc/profile.d/cuda.sh
    echo 'export PATH=/usr/local/cuda-10.0/bin:${PATH}' >> /etc/profile.d/cuda.sh
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-10.0/lib64:${LD_LIBRARY_PATH}' >> /etc/profile.d/cuda.sh

    chmod a+x /etc/profile.d/cuda.sh
    source /etc/profile.d/cuda.sh
    install_tensor_RT
}

function install_tensor_RT()
{    
    echo_step "install tensorRT 5.1.5"
    if [ ! -f $ENV_inst_path/$ENV_tensorRT ];then
        wget $URL_TENSORRT -P $ENV_inst_path
    fi
    dpkg -i $ENV_inst_path/$ENV_tensorRT
    apt-key add /var/nv-tensorrt-repo-cuda10.0-trt5.1.5.0-ga-20190427/7fa2af80.pub
    apt-get update
    apt-get install -y tensorrt
    if [ -d /usr/local/tensorflow/java ];then
        rm -rf /usr/local/tensorflow/java
    fi
    mkdir -p /usr/local/tensorflow/java
    for each_native in ${ENV_tensor_native[@]};
    do
        if [ ! -f $ENV_inst_path/$each_native ];then

            wget $ENV_remote_url$each_native -P $ENV_inst_path
        fi
        cp $ENV_inst_path/$each_native /usr/local/tensorflow/java/.
    done
    
    ln -s /usr/local/tensorflow/java/libtensorflow_framework.so.1.14.1 /usr/local/tensorflow/java/libtensorflow_framework.so.1
    chmod a+x -R /usr/local/tensorflow/java
    
}

function update_tensor_RT_lib()
{
    echo_step "update tensorflow rt to 1.14.1"

    if [ -d /usr/local/tensorflow/java ];then
        rm -rf /usr/local/tensorflow/java
    fi


    mkdir -p /usr/local/tensorflow/java
    for each_native in ${ENV_tensor_native[@]};
    do
        #if [ ! -f $ENV_inst_path/$each_native ];then

        if [ -f $ENV_inst_path/$each_native ];then
            rm $ENV_inst_path/$each_native
            wget $ENV_remote_url$each_native -P $ENV_inst_path
        else
            wget $ENV_remote_url$each_native -P $ENV_inst_path
        fi
        #fi
        cp $ENV_inst_path/$each_native /usr/local/tensorflow/java/.
    done
    ln -s /usr/local/tensorflow/java/libtensorflow_framework.so.1.14.1 /usr/local/tensorflow/java/libtensorflow_framework.so.1
    chmod a+x -R /usr/local/tensorflow/java



}


function install_cudnn()
{
    echo_step "install cudnn 7.5.0"
    echo "install cudnn 7.5.0"
    if [ ! -f $ENV_inst_path/$ENV_cudnn_75 ];then
        wget $URL_CUDNN_UBUNTU16_75 -P $ENV_inst_path  
    fi

    cp $ENV_inst_path/$ENV_cudnn_75 $ENV_release
    tar -xvf /opt/$ENV_cudnn_75 -C $ENV_release
    cp -P /opt/cuda/include/cudnn.h /usr/include/
    cp -P /opt/cuda/lib64/libcudnn* /usr/lib/x86_64-linux-gnu/.
    chmod a+r /usr/lib/x86_64-linux-gnu/libcudnn*

}

function install_display_driver
{
    echo_step "install_display_driver"
    echo "cuda 10 has build in driver 410, skip this step if it not neccessary"

}

function update_nvidia_driver
{

    echo_step "update nvidia driver to 410.93"
    systemctl stop lightdm
    apt-get purge nvidia* -y
    if [ ! -f $ENV_inst_path/$ENV_nvidia_driver ]; then
        wget $URL_NVIDIA_DRIVER -P $ENV_inst_path
    fi
    chmod a+x $ENV_inst_path/$ENV_nvidia_driver
    bash $ENV_inst_path/$ENV_nvidia_driver --no-opengl-files -a
    #bash  $ENV_inst_path/$ENV_nvidia_driver –no-x-check –no-nouveau-check –no-opengl-files -a
    modprobe nvidia
    systemctl start lightdm


}

function install_darner()
{
    echo_step "install darner"
    if [ ! -d /darner ]; then
        echo "no darner, create a new one"
        # add darner to ssh partition
        mkdir -p /darner 
    fi

    chmod -R 777 /darner
    apt-get -y install libboost-program-options-dev libboost-thread-dev libsnappy-dev libleveldb-dev
    if [ ! -f $ENV_inst_path/$ENV_darner ]; then
        wget $URL_DARNER -P $ENV_inst_path
    fi
    cp $ENV_inst_path/$ENV_darner /usr/local/bin/.
    #chown -R $ENV_USER:$ENV_GROU /usr/local/bin/$ENV_darner
    chmod a+x /usr/local/bin/$ENV_darner
    
    #cp $ENV_inst_path/darner.service /lib/systemd/system/.
    echo -e "[unit]\nDescription=darner deamon\nAfter=syslog.target network.target remote-fs.target nss-lookup.target" > /lib/systemd/system/darner.service
    echo -e "[Service]\nType=simple\nExecStart=/usr/local/bin/darner -d /darner -p 22133\nUser=awrun\nGroup=awrun\nKillSignal=SIGTERM\nPrivateTmp=true" >> /lib/systemd/system/darner.service
    echo -e "[Install]\nWantedBy=multi-user.target" >> /lib/systemd/system/darner.service
    systemctl daemon-reload
    systemctl start darner
    systemctl enable darner
}




function install_opencv()
{
    echo_step "install opencv"
    apt-get update
    apt-get -y install yasm x264 v4l-utils libdc1394-22 libtbb2 libgstreamer0.10-0 libgstreamer-plugins-base0.10-0
    apt-get -y install libavcodec-dev libavformat-dev libswscale-dev libqt4-dev libqt5test5 libtesseract-dev \
                       libopenblas-dev liblapacke-dev libavresample-dev libleptonica-dev
    if [ $ENV_OS == '14.04' ];then
        apt-get -y install libhdf5-7 libopenexr6
    elif [ $ENV_OS == '16.04' ]; then
        apt-get -y install libhdf5-10 libopenexr22 libjasper1
        apt-get -y install libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libqt4-dev
    else
        exit 1
    fi
    if [ ! -f $ENV_inst_path/$ENV_opencv ]; then
        wget $URL_OPENCV -P $ENV_inst_path
    fi 

    chmod +xr $ENV_inst_path/$ENV_opencv
    rm /usr/local/OpenCV-3.2.0-x86_64 -rf | true
    rm /usr/local/opencv -rf | true
    $ENV_inst_path/$ENV_opencv --prefix=/usr/local --skip-license --include-subdir
    ln -sf /usr/local/OpenCV-3.2.0-x86_64/ /usr/local/opencv
    if [ ! -f /usr/local/OpenCV-3.2.0-x86_64/libopencv_java320.so ]; then
        if [ -f /usr/local/OpenCV-3.2.0-x86_64/lib/libopencv_world.so.3.2.0 ]; then
            # BUILD_SHARED_LIBS=ON
            ln -sf /usr/local/OpenCV-3.2.0-x86_64/lib/libopencv_world.so.3.2.0 /usr/local/OpenCV-3.2.0-x86_64/lib/libopencv_java320.so
        elif [ -f /usr/local/OpenCV-3.2.0-x86_64/share/OpenCV/java/libopencv_java320.so ]; then
            # BUILD_SHARED_LIBS=OFF
            ln -sf /usr/local/OpenCV-3.2.0-x86_64/share/OpenCV/java/libopencv_java320.so /usr/local/OpenCV-3.2.0-x86_64/lib/libopencv_java320.so
            ln -sf /usr/local/OpenCV-3.2.0-x86_64/python/2.7/cv2.so /usr/local/OpenCV-3.2.0-x86_64/lib/cv2.so | true
        else
            exit "opencv java library not found."
        fi
        if [ ! -f /usr/local/OpenCV-3.2.0-x86_64/lib/libopencv-java320.so ]; then
            ln -sf /usr/local/OpenCV-3.2.0-x86_64/lib/libopencv_java320.so /usr/local/OpenCV-3.2.0-x86_64/lib/libopencv-java320.so
        fi
    fi
    if [ `ldd /usr/local/opencv/lib/libopencv_java320.so | grep "not found"` ]; then
        exit "some depends by libopencv_java320 not found."
    fi

    echo "" > /etc/profile.d/opencv.sh
    echo 'export LD_LIBRARY_PATH=/usr/local/opencv/lib:${LD_LIBRARY_PATH}' >> /etc/profile.d/opencv.sh
    chmod a+x /etc/profile.d/opencv.sh
    source /etc/profile
}

#################################################################################
################################  option  steps    ##############################
#################################################################################

function disable_nouveau()
{
    lsmod | grep nouveau | true
    echo "" > /tmp/blacklist-nouveau.conf
    echo "blacklist nouveau" >> /tmp/blacklist-nouveau.conf
    echo "blacklist lbm-nouveau" >> /tmp/blacklist-nouveau.conf
    echo "options nouveau modeset=0" >> /tmp/blacklist-nouveau.conf
    echo "alias nouveau off" >> /tmp/blacklist-nouveau.conf
    echo "alias lbm-nouveau off" >> /tmp/blacklist-nouveau.conf
    cp /tmp/blacklist-nouveau.conf /etc/modprobe.d/.
}



function make_partition()
{
current_partition=$(lsblk | grep $ENV_DISK_NAME | awk '{print $0}')
#echo $current_partition
if [ -n "$current_partition" ]; then
    echo "make new partition on sdb"
    gdisk /dev/$ENV_DISK_NAME << EOF
n




w
Y
EOF
else

    whiptail --title "Can not locate storage device" --msgbox "$ENV_DISK_NAME not found" 8 78
    echo "disk:$ENV_DISK_NAME not found"
exit 1
fi

mkfs.ext4 -F /dev/"$ENV_DISK_NAME"1
echo "create mount point"

if [ ! -d $ENV_mount_point ]; then
    echo "create root mount point"
    mkdir $ENV_mount_point
    #umount /mount
    mount /dev/"$ENV_DISK_NAME"1 $ENV_mount_point
    echo "/dev/"$ENV_DISK_NAME"1        $ENV_mount_point  ext4    defaults        0       1" >> /etc/fstab

else
    echo "remove old mount point"
    umount $ENV_mount_point
    mount /dev/"$ENV_DISK_NAME"1 $ENV_mount_point
    echo "/dev/"$ENV_DISK_NAME"1        $ENV_mount_point  ext4    defaults        0       1" >> /etc/fstab
fi 

if [ -d "/data" ]; then
    mv /data $ENV_mount_point
    cd /
    ln -s $ENV_mount_point/data data
fi
    if [ -d "/preserve" ]; then
    cd /
    mv /preserve $ENV_mount_point
    ln -s $ENV_mount_point/preserve preserve
fi

}

function set_mysql_backup()
{
if [ ! -f /etc/mysql/installed ];then
    echo "0 3   *   *   0   root    /data/mysql_full_dump.sh > /dev/null 2>&1" >> /etc/crontab
    echo "0 3   *   *   1-6 root    /data/mysql_incremental_backup.sh >/dev/null 2&1" >> /etc/crontab
    echo "log-bin = log-bin.log" >> /etc/mysql/mysql.conf.d/mysqld.cnf
    echo "log-bin-index = log-bin-index" >> /etc/mysql/mysql.conf.d/mysqld.cnf
    echo "binlog-format = ROW" >> /etc/mysql/mysql.conf.d/mysqld.cnf
    echo "server-id=1" >> /etc/mysql/mysql.conf.d/mysqld.cnf
    touch /etc/mysql/installed
fi

cp $ENV_inst_path/mysql_full_dump.sh /data/.
cp $ENV_inst_path/mysql_incremental_backup.sh /data/.

systemctl restart mysql

}

function install_watchdog()
{

    apt-get install watchdog
    cp $ENV_inst_path/watchdog/watchdog.service /lib/systemd/system/.
    cp $ENV_inst_path/watchdog/watchdog.conf /etc/watchdog.conf
    cp $ENV_inst_path/watchdog/watchdog_softdog /etc/default/watchdog
    systemctl daemon-reload
    systemctl start watchdog
    systemctl enable watchdog
}

function install_teamviewer_32bit()
{

    service lightdm stop | true
    systemctl disable lightdm | true
    dpkg --add-architecture i386
    apt-get update | true
    dpkg -i $ENV_inst_path/$ENV_teamviewer
    apt-get -f install -y

    teamviewer license accept | true
    teamviewer daemon enable
    teamviewer daemon restart
    teamviewer passwd \!qAzXsW2#eDc
    sleep 10
    teamviewer_id=$(teamviewer info | grep "TeamViewer ID" | xargs echo )
    echo -e "\033[42;31m$teamviewer_id\033[0m"
}

function install_teamviewer_64bit(){
    apt-get -y install libjpeg62 libxinerama1 libxrandr2:i386 libxtst6:i386 ca-certificates
    if [ ! -f $ENV_inst_path/$ENV_teamviewer ];then
        wget $URL_TEAMVIEWER -P $ENV_inst_path
    fi
    apt-get -y install -f  $ENV_inst_path/$ENV_teamviewer
    sed -i '155s/return/#return/' /opt/teamviewer/tv_bin/script/tvw_aux
    teamviewer license accept | true
    teamviewer daemon enable
    teamviewer daemon restart
    teamviewer passwd \!qAzXsW2#eDc
    sleep 10
    teamviewer_id=$(teamviewer info | grep "TeamViewer ID" | xargs echo )

}

function install_monitorix(){

    apt install -y -f  $ENV_inst_path/$ENV_monitorix
    #cp $ENV_inst_path/monitorix.conf.edge /etc/monitorix/monitorix.conf

    case "$option" in
        "1")
            echo "gpu-server"
            ;;
        "2")
            sed -i "s/title = Place a title here/title = Edge/g" /etc/monitorix/monitorix.conf
            sed -i "s/base_url = \/monitorix/base_url = \//g" /etc/monitorix/monitorix.conf
            sed -i "s/\tlmsens.*= n/\tlmsens\t= y/g" /etc/monitorix/monitorix.conf
            sed -i "s/\tdisk.*= n/\tdisk\t= y/g" /etc/monitorix/monitorix.conf
            sed -i "/core1/a\ \tcore2\t= Core 2\n\tcore3\t= Core 3\n\tcore4\t= Core 4\n\tcore5\t= Core 5" monitorix.conf
            sed -i "s/\tgpu0.*= nvidia/\t#gpu0\t= nvidia/g" /etc/monitorix/monitorix.conf
            sed -i "s/0 = \/dev.*/0 = \/dev\/sda/g" /etc/monitorix/monitorix.conf           
            ;;
        *)
    esac 

    systemctl restart monitorix
    systemctl status monitorix
}

function deploy_deb(){

    dpkg -i $ENV_inst_path/$show_deb 
    systemctl restart nginx

}



function update_kernel(){

    for each_deb in ${ENV_kernel[@]};
    do
        if [ ! -f $ENV_inst_path/$each_deb ];then
            #wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.14.16/$each_deb -P $ENV_inst_path
            wget $ENV_remote_url$each_deb -P $ENV_inst_path
        fi
    done
    dpkg -i $ENV_inst_path/linux-*.deb
}

function install_net_driver(){
    # check if is the intel i219-v network device
    net_hw=`lspci | grep 'Ethernet controller:' | awk {' print $7 '}`
    if [ $net_hw = "15bc" ];then
        cp $ENV_inst_path/$ENV_net_driver /lib/modules/4.4.0-87-generic/.
        cd /lib/modules/4.4.0-87-generic
        modprobe e1000e
        depmod
        sleep 2
        rmmod e1000e
        modprobe e1000e
        ifdown eno1
        echo "auto lo" > /etc/network/interfaces
        echo "iface lo inet loopback" >> /etc/network/interfaces
        echo "auto eno1" >> /etc/network/interfaces
        echo "iface eno1 inet dhcp" >> /etc/network/interfaces
        #ifdown eno1
        ifup eno1
    fi
    
}

function install_zabbix_agent(){
    if [[ -z $option ]];then
        ui_main_menu
        ui_set_zabbix_agnet
    fi
    apt-get -y install zabbix-agent
    cp /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.original
    sed -i "s/^Server=.*$/Server=$zabbix_ip/g" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/^ServerActive=.*$/ServerActive=$zabbix_ip/g" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/^Hostname=.*$/Hostname=$zabbix_hostname/g" /etc/zabbix/zabbix_agentd.conf
    sed -i 's/^.*StartAgents=.*$/StartAgents=0/g' /etc/zabbix/zabbix_agentd.conf #set zabbix working under initiative mode
    hostnamectl set-hostname $zabbix_hostname
    sed -i "s/^.*127.0.1.1.*/127.0.1.1\t$zabbix_hostname/g" /etc/hosts

    echo "UserParameter=teamview.id,teamviewer info | grep \"TeamViewer ID\" | awk -F ' ' '{print substr(\$5,1)}' | xargs echo" > /etc/zabbix/zabbix_agentd.conf.d/common.conf
    echo "UserParameter=$product_branch.uptime,service edge status | grep Active | awk -F \": \" {'print \$2'}" >> /etc/zabbix/zabbix_agentd.conf.d/common.conf
    echo "UserParameter=nginx_status,systemctl is-active nginx --quiet '\$1' && echo 1 || echo 0" >> /etc/zabbix/zabbix_agentd.conf.d/common.conf   
    echo "UserParameter=service_status,systemctl is-active $product_branch --quiet '\$1' && echo 1 || echo 0" >> /etc/zabbix/zabbix_agentd.conf.d/common.conf
    
    if [[ $product_branch == "server" ]];then
        echo "UserParameter=darner_status,systemctl is-active darner --quiet '\$1' && echo 1 || echo 0" > /etc/zabbix/zabbix_agentd.conf.d/server_status.conf
        echo "UserParameter=darner_conn,bash /etc/zabbix/zabbix_agentd.conf.d/check_darner.sh 2>/dev/null" >> /etc/zabbix/zabbix_agentd.conf.d/server_status.conf
        if [ ! -f $ENV_inst_path/$ENV_darner_conn ]; then
            wget $URL_DARNER_CONN -P $ENV_inst_path
        fi
        cp $ENV_inst_path/$ENV_darner_conn /etc/zabbix/zabbix_agentd.conf.d/.  

        echo "UserParameter=camera_number,python /etc/zabbix/zabbix_agentd.conf.d/get_camera_id.py" >> /etc/zabbix/zabbix_agentd.conf.d/server_status.conf
        if [ ! -f $ENV_inst_path/$ENV_camera ]; then
            wget $URL_CAMERA -P $ENV_inst_path
        fi

        cp $ENV_inst_path/$ENV_camera /etc/zabbix/zabbix_agentd.conf.d/.    
        echo "UserParameter=gpu1.temp,nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits -i 0" > /etc/zabbix/zabbix_agentd.conf.d/gpu_status.conf
        echo "UserParameter=gpu1.util,nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits -i 0" >> /etc/zabbix/zabbix_agentd.conf.d/gpu_status.conf
        echo "UserParameter=gpu1.memused,nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits -i 0" >> /etc/zabbix/zabbix_agentd.conf.d/gpu_status.conf
        echo "UserParameter=gpu1.memtotal,nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits -i 0" >> /etc/zabbix/zabbix_agentd.conf.d/gpu_status.conf

        echo "UserParameter=gpu2.temp,nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits -i 1" >> /etc/zabbix/zabbix_agentd.conf.d/gpu_status.conf
        echo "UserParameter=gpu2.util,nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits -i 1" >> /etc/zabbix/zabbix_agentd.conf.d/gpu_status.conf
        echo "UserParameter=gpu2.memused,nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits -i 1" >> /etc/zabbix/zabbix_agentd.conf.d/gpu_status.conf
        echo "UserParameter=gpu2.memtotal,nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits -i 1" >> /etc/zabbix/zabbix_agentd.conf.d/gpu_status.conf
        #echo "UserParameter=cuda_status,nvcc -V | grep \"release\" | awk  '{print \$6}' | xargs echo" >> /etc/zabbix/zabbix_agentd.conf.d/gpu_status.conf
        #echo "UserParameter=cuda_status,ls /usr/local/cuda/bin/nvcc | grep nvcc | wc -l" >> /etc/zabbix/zabbix_agentd.conf.d/gpu_status.conf
        echo "UserParameter=cuda_status,ls /usr/local/ | grep cuda | wc -l" >> /etc/zabbix/zabbix_agentd.conf.d/gpu_status.conf
    fi

    

  
    systemctl restart zabbix-agent

}

function system_init_report(){
    set +e
    ENV_log_name="/opt/inst_log_"$(date +%Y_%m-%d_%H-%M-%S)

    echo "==========server name:"$(hostname)" =============="
    echo "==================== check JDK ======================="
    java -version
    file /etc/alternatives/java /etc/alternatives/javac

    echo "==================== check mysql ====================="
    mysqladmin -uroot -ppassword! version
    echo "==================== check NVIDIA driver ============="
    nvidia-smi -L

    echo "==================== check CUDA status ==============="
    /usr/local/cuda/bin/nvcc -V

    echo "==================== check cudnn ====================="  
    cat /usr/include/cudnn.h | grep define | grep 7 -A 1  

    echo "==================== check nginx ====================="
    systemctl is-active nginx

    /usr/local/nginx/sbin/nginx -v

    echo "==================== check darner ===================="
    systemctl is-active darner  

    echo "==================== check update disable ============"
    cat /etc/apt/apt.conf.d/10periodic  
    echo "-----------------------------------------"
    cat /etc/apt/apt.conf.d/20auto-upgrades  
    echo "-----------------------------------------"
    systemctl status apt-daily{,-upgrade}.{timer,service}  

    echo "==================== check zabbix ===================="
    zabbix_agent -V  

    echo "==================== teamviewer ======================"
    teamviewer info  

    echo "==================== check release version ==========="
    dpkg -l | grep release | grep ii | awk '{ print $2 " - " $3}'

    echo "==================== tensor RT version ==============="
    ls /usr/local/tensorflow/java/libtensorflow_framework.so.1*
    echo "----------  ensorflow_framework_size=25580 ---------"
    ls /usr/local/tensorflow/java/libtensorflow_framework.so.1.14.1 -s | awk '{ print $1 }'
    echo "----------    libtensorflow_jni=770000     ---------"
    ls /usr/local/tensorflow/java/libtensorflow_jni.so -s | awk '{ print $1 }'
    echo "----------         libtftrt=7484           ---------"
    ls /usr/local/tensorflow/java/libtftrt.so -s | awk '{ print $1 }'

    echo "==================== report end ======================"
    echo "======================================================"
    set -e



}

###########################################################################################################
###################################### installation process start #########################################
###########################################################################################################
#STEP 1 invoke UI

function collect_parameters(){
ui_summary_menu
if [[ $summary == "newly_install" ]]; then
    ui_main_menu # will return $optional $deb_files $data_folder
    ui_select_module #will return $module 

    ######### go though options of $module ########

    for check_disk in ${module[@]}
    do

        if [ $check_disk == "make_partition" ];then
            ui_get_disk #will return $ENV_DISK_NAME
        fi
        if [ $check_disk == "install_zabbix_agent" ];then
            ui_set_zabbix_agnet
        fi
    done
    
# statment 1 deb selection
    if [[ $enable_deb == "deploy_deb" ]]; then
        ui_select_deb  # will return $show_deb $show_models
    fi

# select hardware driver and conf for server or gedge

    if [[ $option == "1" ]] || [[ $option == "3" ]] || [[ $option == "4" ]]; then

        ui_hardware_module # will return $hardware_module
        
    fi
    execute_installation

elif [[ $summary == "system_repair" ]]; then
    ui_repair_list
    execute_repair
  
else
    echo ""
fi


}


########### STEP 2 ############

function execute_installation(){

    ############################### basic tools installation ################

    for basic_step in ${generic_steps_1[@]}
    do
        eval $basic_step
    done


    ############################## install selected modules ###################
    for each_module in ${module[@]}
    do
        eval $each_module
    done

    ############################## install all dependencies for server , gedge and iotedge ######################


    if [[ $option == "1" ]]; then

        

        for each_optional_step_1 in ${optional_steps_1[@]}
        do
            eval $each_optional_step_1
        done
        
        for each_driver in ${hardware_module[@]}
        do
            eval $each_driver
        done

        ############################## deploy models for server, gedge and xray ########################

        if [[ ! -z ${show_models} ]];then
                
                for each_model in ${show_models[@]}
                do
                    cp $ENV_inst_path/models/$each_model $data_folder/models
                    chmod -R 755 $data_folder
                done
        fi
        install_jdk
   
    else
        echo "general edge" 
    fi
    


    system_init_report > $ENV_log_name
echo -e "\033[41;44m===== Install Finished. =====\033[0m"
}

function execute_repair(){
    for each_repair_step in ${repair_list[@]}
    do
            if [[ $each_repair_step == "system_init_report" ]];then
                eval $each_repair_step |& tee -a $ENV_log_name
            else
                eval $each_repair_step
            fi
    done
}

collect_parameters
#execute_installation

