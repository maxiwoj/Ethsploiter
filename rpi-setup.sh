# Load module dwc2
echo "dtoverlay=dwc2" >> /boot/config.txt

mkdir runtime

cd /home/pi
dd if=/dev/zero of=usbdisk.img bs=1024 count=1024
mkdosfs ~/usbdisk.img



apt-get install expect hydra sshpass

pip install scapy impacket 
