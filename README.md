![](https://raw.githubusercontent.com/wareck/okcash_build/master/.docs/logo.png)

##Okcash daemon build script for Raspberry Pi ##

----------
This script is for build Okcash headless daemon (okcashd) .

It will make okcashd with static libraries (build from scratch) for a better compatibility/efficiency.

I recommand to use Pi2 or Pi3 otherwise, it will take to much time to synchronise and never staking !

You can use Raspbian Jessie or Strecth (lite or full, better is to use lite version again for efficiency/speed).


----------
## Raspberry pre-build ##

Donwload **Raspbian Stretch** or **Raspbian Jessie** and burn it on your sdcard

Plug the sdcard in your raspberry and start it.

When logged into Raspberry start by an update upgrade :

    sudo apt-get update
    sudo apt-get upgrade
  
Then add essentials tools for starting :

    sudo apt-get install  build-essential autoconf automake libtool pkg-config git screen htop
 
 Now configure your Raspberry :

    sudo raspi-config

( hostname, password , timezone , memory split )

reboot and loggin again

    sudo reboot

## Optimisation ##
This are optional setup, but give you better results :

Dynamic swap file :

    sudo apt-get install dphys-swapfile
    sudo sed -i -e "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=$swap_size_/g" /etc/dphys-swapfile
	sudo dphys-swapfile setup
	sudo dhpys-swapfile swapon    


## Build Okcash ##
Launch scrypt :

	sudo apt-get update
	sudo apt-get install git
	cd /home/pi
	git clone https://github.com/wareck/okcash_build.git bin
	cd /home/pi/bin

now edit options :

    nano deploy.sh
*## Configuration ##*    
*CleanAfterInstall=YES # YES or NO => remove tarballs after install (keep space)*
*Bootstrap=NO # YES or NO => download bootstrap.dat (take long time to start, but better)*
*DefaultConf=YES # YES or NO => install standard*

Save

Start build:

    ./deploy.sh
	
**It will take 2 or 3 hours to build okcashd.**

## Check after build ##
You can check if everithing is ok by use this command:

    okcashd --printtoconsole
If you can see this king of screen, okcashd is running ...
(photo) 

## Auto Start at boot ##
To add okcashd running at raspbbery startup :

    sudo echo "@reboot pi okcashd" >>/etc/crontab


Wareck