# file limits

OPEN_FILE_LIMIT=1024000

sudo sh -c "echo 'session required pam_limits.so' >> /etc/pam.d/common-session"
sudo sh -c "echo 'session required pam_limits.so' >> /etc/pam.d/common-session-noninteractive"
sudo sh -c  "cat <<EOT >> /etc/security/limits.conf

root hard nofile $OPEN_FILE_LIMIT
root hard nproc $OPEN_FILE_LIMIT
root soft nofile $OPEN_FILE_LIMIT
root soft nproc $OPEN_FILE_LIMIT


* hard nofile $OPEN_FILE_LIMIT
* hard nproc $OPEN_FILE_LIMIT
* soft nofile $OPEN_FILE_LIMIT
* soft nproc $OPEN_FILE_LIMIT
EOT"


# log rotation
touch /etc/logrotate.d/allcontainerlogs
sh -c 'cat <<EOT >> /etc/logrotate.d/allcontainerlogs
/var/lib/docker/containers/*/*.log
{
rotate 5
daily
dateext
maxsize 250M
missingok
compress
copytruncate
dateformat -%Y%m%d%H%M%S
create 0644 root root
}
EOT'

# rke2 prerequests

sh -c "cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
vm.panic_on_oom=0
vm.overcommit_memory=1
kernel.panic=10
kernel.panic_on_oops=1
EOF"
#sudo useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U ??

# k8s prerequests

sh -c "cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF"

sh -c "cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF"
sysctl --system