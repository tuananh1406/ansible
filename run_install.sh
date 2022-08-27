#!/bin/bash

if [ -z $1 ];
then
        echo -e "\e[1m\e[100mThiếu tham số. Chạy '$0 python' hoặc '$0 gdnsd'\e[0m";
        exit 255;
fi

PATH_SSH_KEY='./ubuntu_key'
PATH_SSH_KEY_PUB="${PATH_SSH_KEY}.pub"
CURRENT_PWD=$(pwd)
INSTANCE_NAME='UBUNTU1804'

# Kiểm tra ssh key
if [ ! -f "${PATH_SSH_KEY}" ];
then
        # Gen ssh key mới
        ssh-keygen -b 2048 -t rsa -f $PATH_SSH_KEY -q -N "";
fi

SSH_KEY=$(cat "${PATH_SSH_KEY_PUB}")

# Bật ssh
echo -e "\e[1m\e[100mKiểm tra SSH\e[0m"
eval `ssh-agent -s` > /dev/null
ssh-add -q $PATH_SSH_KEY

echo -e "\e[1m\e[100mXoá instance $INSTANCE_NAME (nếu có)\e[0m"
multipass delete $INSTANCE_NAME
multipass purge

echo -e "\e[1m\e[100mKhởi tạo instance $INSTANCE_NAME mới\e[0m"
multipass launch --name $INSTANCE_NAME 18.04 -c 4 -m 8G --cloud-init cloudinit.yml
multipass exec $INSTANCE_NAME -- bash -c "echo ${SSH_KEY} >> /home/ubuntu/.ssh/authorized_keys"

echo -e "\e[1m\e[100mLấy ipv4 của instance mới\e[0m"
IP=$(multipass info ${INSTANCE_NAME} |grep IPv4|awk '{print $2}')
echo -e "\e[1m\e[100mIPv4: $IP\e[0m"

echo -e "\e[1m\e[100mThêm instance vào ansible host\e[0m"
sed -i '/test-1/d' ./hosts
echo "test-1 ansible_host=${IP} ansible_user=ubuntu" >> ./hosts

if [ $1 = 'python' ];
then
        # Cài python 3.6
        echo -e "\e[1m\e[100mKiểm tra python 3 trên instance\e[0m"
        multipass exec ${INSTANCE_NAME} -- python3  --version
        multipass exec ${INSTANCE_NAME} -- bash -c 'ls /usr/local/bin/python3.6'

        echo -e "\e[1m\e[100mCài python3.6.12 bằng ansible\e[0m"
        ansible-playbook -i hosts worker.yml -l test-1 -t install_python

        echo -e "\e[1m\e[100mKiểm tra python 3 trên instance sau khi cài\e[0m"
        multipass exec ${INSTANCE_NAME} -- bash -c 'ls /usr/local/bin/python3.9'
        multipass exec ${INSTANCE_NAME} -- /usr/local/bin/python3.9 --version

        cd $CURRENT_PWD
        exit 0;
fi

if [ $1 = 'gdnsd' ];
then
        # Cài gdnsd
        echo -e "\e[1m\e[100mCài gdnsd bằng ansible\e[0m"
        ansible-playbook -i hosts worker.yml -l test-1 -t install_gdnsd
        echo -e "\e[1m\e[100mKiểm tra gdnsd trên server\e[0m"
        multipass exec ${INSTANCE_NAME} -- sudo bash -c 'gdnsd status; gdnsd checkconf'
fi

if [ $1 = 'logrotate' ];
then
        # Cài logrotate
        echo -e "\e[1m\e[100mCài logrotate bằng ansible\e[0m"
        ansible-playbook -i hosts worker.yml -l test-1 -t install_logrotate
        echo -e "\e[1m\e[100mHiển thị thiết lập của logrotate\e[0m"
        multipass exec ${INSTANCE_NAME} -- sudo bash -c 'stat /etc/logrotate.d/service-log; cat /etc/logrotate.d/service-log'
fi
