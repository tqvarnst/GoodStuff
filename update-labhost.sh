yum install -y yum-utils

yum-config-manager --disable "*"


cat <<EOF > /etc/yum.repos.d/openshift.repo
[rhel-7-server-rpms]
name=Red Hat Enterprise Linux 7 Server (RPMs)
baseurl=http://hpc-dl320a-01.mw.lab.eng.bos.redhat.com/repos/rhel/server/7/$releasever/$basearch/os
enabled=1
gpgcheck=0
skip_if_unavailable=1

[rhel-7-server-extras-rpms]
name=Red Hat Enterprise Linux 7 Server - Extras (RPMs)
baseurl=http://hpc-dl320a-01.mw.lab.eng.bos.redhat.com/repos/rhel/server/7/7Server/$basearch/extras/os
enabled=1
gpgcheck=0
skip_if_unavailable=1

[rhel-7-server-ose-3.1-rpms]
name=Red Hat OpenShift Enterprise 3.1 (RPMs)
baseurl=http://hpc-dl320a-01.mw.lab.eng.bos.redhat.com/repos/rhel/server/7/7Server/$basearch/ose/3.1/os
enabled=1
gpgcheck=0
skip_if_unavailable=1

EOF

yum clean all && yum update -y
