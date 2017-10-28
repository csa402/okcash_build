![](https://raw.githubusercontent.com/wareck/okcash_build/master/.docs/logo.png)

##Build script for Okcash daemon (Raspberry Pi2 & Pi3 & Zero) ##

----------
This script build Okcash headless daemon (okcashd) .

It will make okcashd with static libraries (build from scratch) for a better compatibility/efficiency.

Script will download/compile/configure and build files in autonomous . (it take 2 to 3 hours)

I suggest to use Pi2 or Pi3 otherwise, it will take to much time to synchronise and never staking ...

You can use Raspbian Jessie or Strecth (lite or full, better is to use lite version for efficiency/speed).


----------
## Raspberry pre-build ##

Donwload **Raspbian Stretch** or **Raspbian Jessie** and burn it on your sdcard

Plug the sdcard in your raspberry and start it.

When logged into Raspberry start by an update upgrade :

    sudo apt-get update
    sudo apt-get upgrade
  
Then add essentials tools for starting :

    sudo apt-get install  build-essential git
 
 Now configure your Raspberry :

    sudo raspi-config

( hostname, password , timezone ) 

reboot and loggin again

    sudo reboot

## Build Okcash ##
Launch scrypt :

	sudo apt-get update
	sudo apt-get install git
	cd /home/pi
	git clone https://github.com/wareck/okcash_build.git 
	cd /home/pi/okcash_build

now you can edit options :

    nano deploy.sh
    
*## Configuration ##*  

*CleanAfterInstall=YES # YES or NO => remove tarballs after install (keep space)*

*Bootstrap=NO # YES or NO => download bootstrap.dat (take long time to start, but better)*

*DelFolders=NO # YES or NO => delete build files after finish (keep space on sdcard)*

*PatchCheckPoints=YES # YES or NO => this put new checkpoint to allow okcash sync faster at first start*

*Raspi_optimize=YES # YES or NO => install watchdog, autostart , swap and new kernel for speedup a little / better work*

**Save (crtl+x then y)**

Start build:

    ./deploy.sh
	
**It will take 2 or 3 hours to build okcashd.**

## Check after build ##
You can check if everithing is ok by use this command:

    okcashd --printtoconsole
If you can see this king of screen, okcashd is running ...
(photo) 

wareck@gmail.com
donate Bitcoin :  16F8V2EnHCNPVQwTGLifGHCE12XTnWPG8G
donate Okcash  :  P9q7UeQVgAk9QKJz5v76FZ9xPWmE56Leu8