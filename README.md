![](https://raw.githubusercontent.com/wareck/okcash_build/master/.docs/logo.png)

## Build script for Okcash daemon (Raspberry Pi2 & Pi3) ##

----------
This script build "Okcash headless daemon" (okcashd command line only, for best efficiency) .

It will make okcashd with static libraries (build from scratch) for a better compatibility/efficiency.

Script will download/compile/configure and build files in autonomous . (it take 2 to 3 hours)

I suggest to use Pi2 or Pi3 otherwise, it will take to much time to synchronise and never staking ...

You can use Raspbian Jessie or Strecth (lite or full, better is to use lite version for efficiency/speed).


----------
## Raspberry pre-build ##

Donwload **Raspbian Stretch** or **Raspbian Jessie** from https://www.raspberrypi.org/

***If you planned to use a hudge sdcard (minimum 16GB) , just burn image on sdcard and jump to step 3.***

**If you planned to use a standard sdcard + usb key: (best) do all step...**


Step 1 : ***Burn your card and plug it in your raspberry , start it.***

When logged into Raspberry start by an update upgrade :

    sudo apt-get update
    sudo apt-get upgrade
  
Then add essentials tools for starting :

    sudo apt-get install  build-essential git
 
 Now configure your Raspberry :

    sudo raspi-config

( hostname, password , timezone ) 

Step 2 : ***If you wants to use an USB key*** 

plug you key in your raspberry pi now, (must be formated in VFAT or EXT4), let in plugged during build/installation

Now prepare you raspberry to use usb instead of sdcard forlder:

    mkdir /home/pi/.okcash
	sudo nano /etc/fstab

add this line to fstab (**for vfat**)

    /dev/sda1 /home/pi/.okcash  vfat uid=pi,gid=pi,umask=0022,sync,auto,nosuid,rw,nouser    0    0

add this line to fstab (**for ext4**)

    /dev/sda1       /home/pi/.okcash        ext4 defaults 0 0

Step 3 : ***reboot and login again***

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

wareck : wareck@gmail.com
donate Bitcoin :  16F8V2EnHCNPVQwTGLifGHCE12XTnWPG8G
donate Okcash  :  P9q7UeQVgAk9QKJz5v76FZ9xPWmE56Leu8
