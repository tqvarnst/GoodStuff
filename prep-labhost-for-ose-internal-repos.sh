#!/bin/bash

grep registry.access.redhat.com /etc/hosts || printf '209.132.182.63\tregistry.access.redhat.com\n' | tee -a /etc/hosts

LV_SIZE=$(echo $(lvdisplay "/dev/rhel_$(hostname -s)/home" | awk "/Current LE/") | cut -d " " -f3)
if [ "$LV_SIZE" -gt "100000" ]; then
    lvreduce -f -l -40000 "/dev/rhel_$(hostname -s)/home"
else
    echo "There is NOT enough space left on logical volume home!!!"
fi

curl -o /etc/yum.repo.d/RH7-RHAOS-3.1.repo http://hpc-dl320a-01.mw.lab.eng.bos.redhat.com/OSE3.1/RH7-RHAOS-3.1.repo

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

grep ".mw.lab.eng.bos.redhat.com" /etc/ssh/ssh_config || printf "
Host *.mw.lab.eng.bos.redhat.com
   StrictHostKeyChecking no
   UserKnownHostsFile /dev/null
" | tee -a /etc/ssh/ssh_config


grep -q "dm.thinpooldev" /etc/sysconfig/docker-storage || docker-storage-setup

test -e /root/.ssh/id_rsa || ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa

systemctl stop docker
rm -rf /var/lib/docker/*
systemctl restart docker
