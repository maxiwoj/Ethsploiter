#!/bin/sh

# ethsploiter_startup.sh

cd /sys/kernel/config/usb_gadget/
mkdir -p ethsploiter
cd ethsploiter

HOST="48:6f:73:74:50:43"
SELF0="42:61:64:55:53:42"
SELF1="42:61:64:55:53:43"

# echo 0x04b3 > idVendor
# echo 0x4010 > idProduct
echo 0x1d6b > idVendor   # Linux Foundation
echo 0x0104 > idProduct  # Multifunction Composite Gadget

echo 0x0100 > bcdDevice # v1.0.0
mkdir -p strings/0x409
echo "badc0deddeadbeef" > strings/0x409/serialnumber
echo "Linux Foundation" > strings/0x409/manufacturer
echo "Internet Connection" > strings/0x409/product

# Config 1: RNDIS
mkdir -p configs/c.1/strings/0x409
echo "0x80" > configs/c.1/bmAttributes
echo 250 > configs/c.1/MaxPower
echo "Config 1: RNDIS network" > configs/c.1/strings/0x409/configuration

echo "1" > os_desc/use
echo "0xcd" > os_desc/b_vendor_code
echo "MSFT100" > os_desc/qw_sign

mkdir -p functions/rndis.usb0
echo $SELF0 > functions/rndis.usb0/dev_addr
echo $HOST > functions/rndis.usb0/host_addr
echo "RNDIS" > functions/rndis.usb0/os_desc/interface.rndis/compatible_id
echo "5162001" > functions/rndis.usb0/os_desc/interface.rndis/sub_compatible_id


# Config 2: CDC ECM
mkdir -p configs/c.2/strings/0x409
echo "Config 2: ECM network" > configs/c.2/strings/0x409/configuration
echo 250 > configs/c.2/MaxPower

mkdir -p functions/ecm.usb0
# first byte of address must be even
echo $HOST > functions/ecm.usb0/host_addr
echo $SELF1 > functions/ecm.usb0/dev_addr

# Link everything and bind the USB device
ln -s configs/c.1 os_desc
ln -s functions/rndis.usb0 configs/c.1

ln -s functions/ecm.usb0 configs/c.2
ls /sys/class/udc > UDC

# Mass Storage
cd ..
mkdir -p mass_storage
cd mass_storage

echo 0x1d6b > idVendor   # Linux Foundation
echo 0x0104 > idProduct  # Multifunction Composite Gadget

echo 0x0100 > bcdDevice # v1.0.0
mkdir -p strings/0x409
echo "bedc0deddeadbeef" > strings/0x409/serialnumber
echo "Linux Foundation" > strings/0x409/manufacturer
echo "Mass Storage Device" > strings/0x409/product

mkdir -p configs/c.1/strings/0x409
echo "Config 3: Mass storage" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower

mkdir -p functions/mass_storage.usb1/lun.0
echo /home/pi/usbdisk.img > functions/mass_storage.usb1/lun.0/file
echo 0 > functions/mass_storage.usb1/stall
echo 0 > functions/mass_storage.usb1/lun.0/cdrom
echo 0 > functions/mass_storage.usb1/lun.0/nofua
echo 1 > functions/mass_storage.usb1/lun.0/removable
ln -s functions/mass_storage.usb1 configs/c.1/
ln -s configs/c.1 os_desc

# Create the CDC ACM function
#mkdir -p functions/acm.gs0

#ln -s functions/acm.gs0 configs/c.2

# End functions
ls /sys/class/udc > UDC

