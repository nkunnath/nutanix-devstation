#cloud-config
user: nutanix
password: nutanix/4u 
chpasswd: {expire: False}
sudo: ALL=(ALL) NOPASSWD:ALL
ssh_pwauth: True
fqdn: ${hostname}.test.local
hostname: ${hostname}

apt_upgrade: true
packages:
   - python-is-python3
#   - python3-pip

