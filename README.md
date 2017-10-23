![](https://raw.githubusercontent.com/wareck/okcash_build/master/.docs/logo.png)

## Okcash build for Raspberry Pi ##

This script if for build an headless daemon for OKcash (okcashd).
This is better to use on PI2 or PI3 (otherwise, it will tooo looong to synchronise and staking !)
You can use Raspbian Jessie or Strecth (lite or full, better is to use lite version).

### Operation ###
To use this code:

	sudo apt-get update
	sudo apt-get install git
	cd /home/pi
	git clone https://github.com/wareck/okcash_build.git bin
	cd bin
	./deploy.sh
	
It will take 2 or 3 hours to build okcashd.
Then you'll have to edit the /home/pi/.okcash/okcash.conf file

...work in progress...