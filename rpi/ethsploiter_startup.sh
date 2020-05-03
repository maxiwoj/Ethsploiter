# ethsploiter_startup.sh

ifup usb0
ifconfig usb0 up
service isc-dhcp-server start