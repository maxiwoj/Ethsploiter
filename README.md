# Ethsploiter

> An ethernet card emulator for exploiting network vulnerabilities in local environment.

[![Release](https://img.shields.io/github/release/maxiwoj/Ethsploiter.svg?style=flat-square)](https://github.com/maxiwoj/Ethsploiter/releases/latest) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/maxiwoj/Ethsploiter/blob/master/LICENSE)

Ethsploiter is a device for tricking the computer behind a firewall (or not connected to the Internet at all) and exploiting vulnerabilities that are not accessible from the Internet. The computer does not need to be unlocked for the attack to succeed. 
It uses `libcomposite` module with `ConfigFS` for emulation and is highly extendable, the configuration can be dynamically changed during the attack for extending the attack vector and emulation of e.g. HID. 

Implemented attacks are just a proof of concept of the attack and will probably not work on fully updated systems. It is possible to implement more exploits that could be used against updated software. 

![schema](https://raw.githubusercontent.com/maxiwoj/Ethsploiter/master/img/emulation_attack_schema.png)

## Features
- exploiting locked computers in private/isolated networks through USB
- emulation of composite device (USB Mass Storage device + Ethernet over USB card)
- fully automated attack process that triggers various exploits

### Demo
Demo is available on YouTube:

[![Youtube video](https://img.youtube.com/vi/Uiu7IylVNGs/0.jpg)](https://youtu.be/Ufcg1w15s0U)


## Instalation
### Prerequisites
In order to use the Ethsploiter the user needs:
- Raspberry Pi Zero
- MicroUSB-USB cable to connect Raspberry Pi to the target computer

### Clone
Clone the repository on your raspberry pi into the home directory of user pi (can also be other, but some adjustments will have to be made) using git:
```shell
$ git clone git@github.com:maxiwoj/Ethsploiter.git
```
### Setup
The consists of 2 main directories: 
- exploits - this directory contains all the exploit scripts, that are used to exploit the computer.
- rpi - this directory contains files in directories that represent the raspberry pi `/` directory. Some files are need to be placed under `/boot` directory, some in `etc`. In order to setup the Raspberrry Pi the user needs to copy appropriate files to appropriate directories. 

Some required adjustments and installations are made by running the script:

```shell
$ cd Ethsploiter
$ ./rpi-setup.sh
```

## Usage
After successfull configuration of the raspberry Pi, the only thing that needs to be done is to plug the device the computer. It can be done by connecting the microUSB cable with the standard USB port on the computer. Please note, however, that the cable needs to be plugged to the host socket of the raspberry, not the one used for charging (no extra charing is required for this setup).

![connection](https://raw.githubusercontent.com/maxiwoj/Ethsploiter/master/img/connection_schema.png)

### Troubleshooting
When configuring the device, some problems may appear. Some Information and commands below might be helpful to debug and find the reason of the problem:

Logs of the `rc.local` service can be retrieved using commend:
```shell 
$ systemctl status rc.local.service
```

Some events with USB are logged system-wide and can be retrieved by using the good old friend: 
```shell
$ dmesg
```

If the ethernet card is not identified correctly, the problem probably is connected with the `libcomposite` configuration. `libcomposite` module configuration by `ConfigFS` is run from the rc.local service and all the output is saved by default to:
`/home/pi/Ethsploiter/runtime/ethsploiter_startup.log`. 

The attack logs are stored by default in: `/home/pi/Ethsploiter/runtime/attack.log`. However, this file contains only general logs - every attack creates a separate file for logs. Paths to all those files are printed in the attack log file. 

## Documentation

### Ethernet card emulation
Since the solution has been designed to work with all most popular operating systems (Windows, Linux, OS X) the configuration had to be adjusted. There are 2 major ethernet over USB protocols (RNDIS and CDC ECM) and not all systems support all of them. Linux based operating systems have support for both protocols, but Windows supports only RNDIS and OS X only CDC ECM. In order for all the systems to work, there has been created 2 separate configurations for both protocols. Configurations are connected to USB0 and USB1 network interfaces that are spanned by virtual interface - BR0 (bridge) in order to simplify further interaction with the created network.

![Network Configuration](https://raw.githubusercontent.com/maxiwoj/Ethsploiter/master/img/network_configuration.png)

### libcomposite configurations
For emulating the ethernet card (in a composite device) a `libcomposite` module has been used. Configuration for the `libcomposite` module can be found in the file [ehtslploiter_startup](https://github.com/maxiwoj/Ethsploiter/blob/master/rpi/ethsploiter_startup.sh). It is a script that creates all the necessary files through `ConfigFS`. The overall configuration of the libcomposite module is shown below: 

![Libcomposite configuration](https://raw.githubusercontent.com/maxiwoj/Ethsploiter/master/img/libcomposite_configuration.png)

The device emulates simultaneously a network card as well as a mass storage device (as a composite device). 

### DHCP server
In order for every computer to recognise a new network (that the emulated card is giving access to) it is required to contain a DHCP server that could respond with an IP address for the computer. In the configuration a mock DHCP server has been created that always responds with the same IP address since there is only one computer connected to the network (victim's computer). This simplifies the configuration (no need to discover the victim's computer address, no DHCP server configuration) and also at the same time tries to exploit the shellshock vulnerability that was present in some older DHCP client services. 

## Contributions and Further development
Contributions are more than welcome, most valuable are the ones that implement functionalities stated in the 'TODOs' section in the bottom of README. 

## Authors and acknowledgment
This project has been created as an experiment during the master thesis research on the AGH University of Science and Technology in Cracow under supervision of [dr Łukasz Faber](https://github.com/Nnidyu). The investigation concerned "Emulation of devices as a penetration testing method".

## License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/maxiwoj/Ethsploiter/blob/master/LICENSE)

This project is just a result of an experiment testing the security in a local environment. It has neither been created nor designed for any illegal purposes. 

## TODOs
- implementation of a setup script automating the Raspberry Pi setup
- implementation of more general attacks that could use the advantage of direct connection to the computer
- implement a fully working composite device configuration that could be successfully recognised by the most popular operating systems (Winodows, Linux and OS X - currently on Windows only Ethernet card is being recognised fromt the composite device)
- integration with other USB exploiting tools (such as poison tap or Rubber ducky)


