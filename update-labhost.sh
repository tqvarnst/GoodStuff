yum install -y yum-utils

yum-config-manager --disable "*"


echo "[latest-RHEL-7]
name=latest-RHEL-7
baseurl=http://download.eng.bos.redhat.com/devel/candidates/latest-RHEL-7/compose/Server/x86_64/os/
enabled=1
gpgcheck=0
skip_if_unavailable=1" > /etc/yum.repos.d/latest-RHEL-7.repo

echo "[latest-EXTRAS-7-RHEL-7]
name=latest-EXTRAS-7-RHEL-7
baseurl=http://download.eng.bos.redhat.com/devel/candidates/latest-EXTRAS-7-RHEL-7/compose/Server/x86_64/os
enabled=1
gpgcheck=0
skip_if_unavailable=1" > /etc/yum.repos.d/latest-EXTRAS-7-RHEL-7.repo

yum clean all && yum update -y
