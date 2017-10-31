#!/bin/bash
#Okcash headless 4.0.0.4g RPI Working (sync enable, staking enable)
#Best results found was : Boost 1.58 / Openssl 1.0.2g / DB 4.8-30 / OkCash 4.0.0.4g
set -e
Version=1.4g

################
##Configuration#
################

#Remove tarball at end of install (keep some space on card)
CleanAfterInstall=NO # YES or NO => remove tarballs after install (keep space)

#Bootstrap (speedup first start, but requier 2GB free space on sdcard)
Bootstrap=YES # YES or NO => download bootstrap.dat (take long time to start, but better)

#Delete folder after compile/install (keep free space)
DelFolders=NO

#Build okcash with Checkpoint patched (speedup the first start, don't check 1113700 first block)
PatchCheckPoints=YES #speedup init (start check database at last checkpoint)

#Optimiser Raspberry (give watchdog function and autostart okcash, speedup a little the raspberry)
Raspi_optimize=YES

#Website frontend (give a small web page to check if everything is ok)
Website=NO

echo -e "\n\e[97mOkcash headless builder version $Version\e[0m"
echo -e "wareck@gmail.com"
echo -e "\nConfiguration"
echo -e "-------------"
echo -e "Download Bootstrap.dat        : $Bootstrap"
echo -e "Delete tarballs after build   : $CleanAfterInstall"
echo -e "Delete build directory        : $DelFolders"
echo -e "Patching Checkpoints.cpp      : $PatchCheckPoints"
echo -e "Raspberry Optimisation        : $Raspi_optimize"
echo -e "Website Frontend              : $Website"

sleep 5


function Download_Expand_ {
sudo apt-get update
sudo apt-get install libbz2-dev liblzma-dev libzip-dev zlib1g-dev python-dev ntp pwgen -y
sudo sed -i -e "s/# set const/set const/g" /etc/nanorc
echo -e "\n\e[95mDownload and expand boost library :\e[0m"
if ! [ -d /home/pi/okcash_build/boost_1_58_0 ]
then
wget -c http://wareck.free.fr/okcash/boost_1_58_0.tar.xz
tar xvfJ boost_1_58_0.tar.xz
fi

echo -e "\n\e[95mDownload and expand openssl library:\e[0m"
if ! [ -d /home/pi/okcash_build/openssl-1.0.2g ]
then
wget -c http://wareck.free.fr/okcash/openssl-1.0.2g.tar.xz
tar xvfJ openssl-1.0.2g.tar.xz
fi

echo -e "\n\e[95mDonwload and expand miniupnpc library:\e[0m"
if ! [ -d /home/pi/okcash_build/miniupnpc-2.0.20170509 ]
then
wget -c http://wareck.free.fr/okcash/miniupnpc-2.0.20170509.tar.xz
tar xvfJ miniupnpc-2.0.20170509.tar.xz
fi

echo -e "\n\e[95mDownload and Expand db-4.8.30 library\e[0m"
if ! [ -d /home/pi/okcash_build/db-4.8.30.NC ]
then
wget -c http://wareck.free.fr/okcash/db-4.8.30.NC.tar.xz
tar xvfJ db-4.8.30.NC.tar.xz
fi

echo -e "\n\e[95mDownload OkCash V4.0.0.4g\e[0m"
if ! [ -d /home/pi/okcash_build/okcash ]
then
git clone -n https://github.com/okcashpro/okcash.git || true
cd okcash
git checkout 4d47b31ff318627bdb48fb4a9b0b384b9ebd2a09
if [ $PatchCheckPoints = "YES" ]
then
echo -e "\n\e[97mPatching Checkpoints : \e[0m"
patch -p1 < ../checkpoint.patch
echo -e "Done !"
sleep 5
fi
cd ..

fi

}

function Build_Dependencies_ {
echo
echo -e "\n\e[95mBuild Openssl\e[0m"
cd openssl-1.0.2g
./Configure no-zlib no-shared no-dso no-krb5 no-camellia no-capieng no-cast no-dtls1 no-gost no-gmp no-heartbeats no-idea no-jpake no-md2 no-mdc2 no-rc5 no-rdrand no-rfc3779 no-rsax no-sctp no-seed no-sha0 no-static_engine no-whirlpool no-rc2 no-rc4 no-ssl2 no-ssl3 linux-armv4
make depend
make
cd ..

echo -e "\n\e[95mBuild DB-4.8.30\e[0m"
if [ -f /usr/share/man/man3/miniupnpc.3.gz ]; then sudo rm /usr/share/man/man3/miniupnpc.3.gz; fi
cd db-4.8.30.NC
cd build_unix
../dist/configure --enable-cxx
make
sudo make install
sudo ln -s /usr/local/BerkeleyDB.4.8/lib/libdb_cxx-4.8.so /usr/lib/ || true
cd ..
cd ..

echo -e "\n\e[95mBuild Boost 1_58_0\e[0m"
cd boost_1_58_0
./bootstrap.sh
sudo ./b2 --with-chrono --with-filesystem --with-program_options --with-system --with-thread toolset=gcc variant=release link=static threading=multi runtime-link=static install
cd ..

echo -e "\n\e[95mBuild miniupnpc 2.0\e[0m"
cd miniupnpc-2.0.20170509
make
sudo make install
cd ..

echo
echo -e "\n\e[97mDependencies done !\e[0m"
if ! [ -f .pass1 ]
then
touch .pass1
fi
}

function Build_Okcash_ {
echo -e "\n\e[95mBuild OkCash\e[0m"
cd okcash
cd src
make -f makefile.unix OPENSSL_LIB_PATH=/home/pi/okcash_build/openssl-1.0.2g OPENSSL_INCLUDE_PATH=/home/pi/okcash_build/openssl-1.0.2g/include BDB_INCLUDE_PATH=/usr/local/BerkeleyDB.4.8/include/ BDB_LIB_PATH=/usr/local/BerkeleyDB.4.8/lib BOOST_LIB_PATH=/usr/local/lib/ BOOST_INCLUDE_PATH=/usr/local/include/boost/ #MINIUPNPC_INCLUDE_PATH=/usr/include/miniupnpc MINIUPNPC_LIB_PATH=/usr/lib/ USE_UPNP=1
strip okcashd
sudo cp okcashd /usr/local/bin ||true
}

function conf_ {
if ! [ -f /home/pi/.okcash/okcash.conf ]
then
echo -e "\n\e[95mInstall okcash.conf\e[0m"
mkdir /home/pi/.okcash/
touch /home/pi/.okcash/okcash.conf
cat <<'EOF'>> /home/pi/.okcash/okcash.conf
#Daemon and listen ON/OFF
daemon=1
listen=1
staking=1

#Connection User and Password
rpcuser=wareck51
rpcpassword=zorn69

#Authorized IPs
rpcallowip=127.0.0.1
rpcport=16969
port=16970

#write the location for this blockchain below if not on standard directory
datadir=/home/pi/.okcash

#Add extra Nodes
addnode=180.34.138.133
addnode=150.249.117.19
addonde=99.227.239.19.229
addnode=192.168.1.11
addnode=192.168.1.100
EOF
fi
echo "Done !"
}


if ! [ -f .pass1 ]
then
echo -e "\n\e[95mDownload dependencies and build libraries :\e[0m"
Download_Expand_
Build_Dependencies_
else
echo ""
echo "Dependencies were already builded..."
echo "Remove .pass1 to restart build..."
echo
sleep 5
fi
sudo ldconfig
Build_Okcash_
killall -9 okcashd || true

if [ $Bootstrap = "YES" ]
then
echo -e "\n\e[95mDownload Bootstrap.dat :\e[0m"
cd /home/pi
wget -c http://wareck.free.fr/okcash/bootstrap.tar.xz
tar xvfJ bootstrap.tar.xz
sleep 1
rm /home/pi/bootstrap.tar.xz
fi

conf_

if [ $CleanAfterInstall = "YES" ]
then
echo -e "\n\e[95mCleaning :\e[0m"
cd /home/pi/okcash_build
rm boost_1_58_0.tar.xz || true
rm openssl-1.0.2g.tar.xz ||true
rm miniupnpc-2.0.20170509.tar.xz || true
rm db-4.8.30.NC.tar.xz || true
fi
if [ $DelFolders = "YES" ]
then
echo -e "\n\e[95mCleaning folders:\e[0m"
echo -e "Remove openssl-1.0.2g"
sudo rm -r -f openssl-1.0.2g  || true
echo -e "Remove miniupnpc-2.0.20170509"
sudo rm -r -f miniupnpc-2.0.20170509 || true
echo -e "Remove db-4.8.30.NC"
sudo rm -r -f db-4.8.30.NC || true
echo -e "Remove boost_1_58_0"
sudo rm -r -f boost_1_58_0 || true
echo -e "Remove Okcash Folder"
sudo rm -r -f okcash ||true
if [ -f .pass1 ];then rm .pass1;fi
fi

echo "Done !!!"

if [ $Website = "YES" ]
then
echo -e "\n\e[95mWebsite Frontend installation:\e[0m"
sudo apt-get install apache2 php5 php5-xmlrpc curl php5-curl
cd /var/www/
if ! [ -d /var/www/html ]
then
sudo bash -c 'git clone https://github.com/csa402/okcash_nodestatus.git html'
sudo bash -c 'sudo cp /var/www/html/php/config.sample.php /var/www/html/php/config.php'
fi
cd /home/pi
if  ! grep "curl -Ssk http://127.0.0.1/stats.php" /etc/crontab >/dev/null
then
sudo bash -c 'echo "*/5 *  *   *   *  curl -Ssk http://127.0.0.1/stats.php > /dev/null" >>/etc/crontab | sudo -s'
sudo bash -c 'echo "*/5 *  *   *   *  curl -Ssk http://127.0.0.1/peercount.php > /dev/null" >>/etc/crontab | sudo -s'
fi
echo -e "Done"
fi

if [ $Raspi_optimize = "YES" ]
then
echo -e "\n\e[95mRaspberry Optimisation:\e[0m"
echo -e "\n\e[95mkernel Update:\e[0m"
sudo rpi-update
echo -e "\n\e[95mWatchDog and Autostart :\e[0m"
sudo apt-get install watchdog chkconfig -y
sudo chkconfig watchdog on
sudo /etc/init.d/watchdog start
sudo update-rc.d watchdog enable
if ! [ -f /home/pi/watchdog.sh ]
then
cat <<'EOF'>> /home/pi/watchdog.sh
#!/bin/bash
if ps -ef | grep -v grep | grep okcashd >/dev/null
then
exit 0
else
okcashd --printtoconsole
exit 0
fi
EOF
fi
chmod +x /home/pi/watchdog.sh
echo -e "\n\e[97mEnabling and tunning Watchdog:\e[0m"
sudo bash -c 'sed -i -e "s/#watchdog-device/watchdog-device/g" /etc/watchdog.conf'
sudo bash -c 'sed -i -e "s/#interval             = 1/interval            = 4/g" /etc/watchdog.conf'
sudo bash -c 'sed -i -e "s/#RuntimeWatchdogSec=0/RuntimeWatchdogSec=14/g" /etc/systemd/system.conf'
if ! [ -f /etc/modprobe.d/bcm2835_wdt.conf ]
then
sudo bash -c 'touch /etc/modprobe.d/bcm2835_wdt.conf'
sudo bash -c 'echo "alias char-major-10-130 bcm2835_wdt" /etc/modprobe.d/bcm2835_wdt.conf'
sudo bash -c 'echo "alias char-major-10-131 bcm2835_wdt" /etc/modprobe.d/bcm2835_wdt.conf'
sudo bash -c 'echo "bcm2835_wdt" >>/etc/modules'
fi
echo -e "Done !"

echo -e "\n\e[97mWatchdog batch & crontab :\e[0m"
if  ! grep "/home/pi/watchdog.sh" /etc/crontab >/dev/null
then
sudo bash -c 'echo "#okcash watchdog" >>/etc/crontab | sudo -s'
sudo bash -c 'echo "*/5    * * * * pi   /home/pi/watchdog.sh" >>/etc/crontab'
fi
echo "Done !"


echo -e "\n\e[97mrc.local batch:\e[0m"
if ! grep "su - pi -c 'okcashd --printtoconsole'" /etc/rc.local >/dev/null
then
sudo bash -c 'sed -i -e "s/exit 0//g" /etc/rc.local'
sudo bash -c 'echo "su - pi -c \"okcashd --printtoconsole\"" >> /etc/rc.local'
sudo bash -c 'echo "exit 0" >>/etc/rc.local'
fi
echo -e "Done !"

echo -e "\n\e[95mEnable Swap :\e[0m"
sudo apt-get install dphys-swapfile -y
sudo bash -c 'sed -i -e "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/g" /etc/dphys-swapfile'
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
echo -e "Done !"

echo -e "\n\e[95mEnable Memory split :\e[0m"
if ! grep "gpu_mem=16" /boot/config.txt >/dev/null
then
sudo bash -c 'echo "gpu_mem=16" >>/boot/config.txt'
fi
echo -e "Done !"

echo -e "\n\e[92mRaspberry optimized : need to reboot .\e[0m"
fi
if [ $Website = "YES" ]
then
echo -e "\n\e[92mDon't forget to edit your /var/www/html/php/config.php file ...\e[0m"
fi

echo -e "\n\e[97mBuild is finished !!!\e[0m"
echo ""
echo "wareck@gmail.com"
echo "Donate Bitcoin : 16F8V2EnHCNPVQwTGLifGHCE12XTnWPG8G || OKcash : P9q7UeQVgAk9QKJz5v76FZ9xPWmE56Leu8"

sleep 3
