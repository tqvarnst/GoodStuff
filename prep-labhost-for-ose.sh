#!/bin/bash

RHN_USERNAME=$1
RHN_PASSWD=$2

if [ -z ${RHN_USERNAME} ]; then
    printf "ERROR: You must specify your Red Hat Account as first parameter\n"
    exit 1
fi

if [ -z ${RHN_PASSWD} ]; then
    printf "ERROR: You must specify your Red Hat Password as second parameter\n"
    exit 2
fi

grep registry.access.redhat.com /etc/hosts || printf '209.132.182.63\tregistry.access.redhat.com\n' | tee -a /etc/hosts
iptables --check INPUT -i eth0 -p tcp --dport 22 2>/dev/null || iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables --check OUTPUT -o eth0 -p tcp --sport 22 2>/dev/null || iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables-save > /etc/sysconfig/iptables

LV_SIZE=$(echo $(lvdisplay "/dev/rhel_$(hostname -s)/home" | awk "/Current LE/") | cut -d " " -f3)
if [ "$LV_SIZE" -gt "100000" ]; then
    lvreduce -f -l -40000 "/dev/rhel_$(hostname -s)/home"
else
    echo "There is NOT enough space left on logical volume home!!!"
fi
rm -f /etc/yum.repos.d/*
if subscription-manager status > /dev/null; then
    echo "System is already registred"
else
    subscription-manager register --username=${RHN_USERNAME} --password=${RHN_PASSWD}
    subscription-manager attach --pool=8a85f9843e3d687a013e3ddd46dd07f1
    subscription-manager repos --disable="*"
    subscription-manager repos --enable="rhel-7-server-rpms" \
        --enable="rhel-7-server-extras-rpms" \
        --enable="rhel-7-server-ose-3.1-rpms"
fi

yum update -y

yum install -y wget git \
    net-tools \
    bind-utils \
    iptables-services \
    bridge-utils \
    bash-completion \
    openssl \
    atomic-openshift-utils \
    docker

sed -i "/OPTIONS=/c OPTIONS=\"--selinux-enabled --insecure-registry 172.30.0.0/16\"" /etc/sysconfig/docker

grep -q "dm.thinpooldev" /etc/sysconfig/docker-storage || docker-storage-setup

test -e /root/.ssh/id_rsa || ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa

systemctl stop docker
rm -rf /var/lib/docker/*
systemctl restart docker
