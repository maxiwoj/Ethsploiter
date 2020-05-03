echo "dtoverlay=dwc2" >> /boot/config.txt
sudo sed --in-place "/exit 0/d" /etc/rc.local
echo "/bin/sh /ethsploiter_startup.sh" > /etc/rc.local
echo "exit 0" > /etc/rc.local