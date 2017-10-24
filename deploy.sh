#!/bin/bash
set -e
Version=1.2

##Configuration
CleanAfterInstall=YES # YES or NO => remove tarballs after install (keep space)
Bootstrap=NO # YES or NO => download bootstrap.dat (take long time to start, but better)
DefaultConf=YES # YES or NO => install standard 

function decompress {
sudo apt-get update
sudo apt-get install libbz2-dev liblzma-dev libzip-dev zlib1g-dev python-dev ntp -y
sudo sed -i -e "s/# set const/set const/g" /etc/nanorc
echo -e "\e[95mDecompress boost...\e[0m"
if ! [ -d /home/pi/bin/boost_1_58_0 ]
then
wget -c http://farman-aeromodelisme.fr/hors_site/okcash/boost_1_58_0.tar.gz
tar xvfz boost_1_58_0.tar.gz
fi

echo -e "\e[95mDecompress openssl...\e[0m"
if ! [ -d /home/pi/bin/openssl-1.0.2l ]
then
wget -c http://farman-aeromodelisme.fr/hors_site/okcash/openssl-1.0.2l.tar.gz
tar xvfz openssl-1.0.2l.tar.gz
fi

echo -e "\e[95mDecompress miniupnpc...\e[0m"
if ! [ -d /home/pi/bin/miniupnpc-1.9.20140401 ]
then
wget -c http://farman-aeromodelisme.fr/hors_site/okcash/miniupnpc-1.9.20140401.tar.gz
tar xvfz miniupnpc-1.9.20140401.tar.gz
fi

echo -e "\e[95mDecompress db-4.8.30...\e[0m"
if ! [ -d /home/pi/bin/db-4.8.30.NC ]
then
wget -c http://farman-aeromodelisme.fr/hors_site/okcash/db-4.8.30.NC.tar.gz
tar xvfz db-4.8.30.NC.tar.gz
fi

echo -e "\e[95mDecompress okcash...\e[0m"
if ! [ -d /home/pi/bin/okcash ]
then
git clone https://github.com/okcashpro/okcash.git || true
else
cd /home/pi/bin/okcash
git pull
cd /home/pi/bin
fi

}

function deps {
echo
echo -e "\e[95mBuild Openssl\e[0m"
cd openssl-1.0.2l
./Configure no-zlib no-shared no-dso no-krb5 no-camellia no-capieng no-cast no-dtls1 no-gost no-gmp no-heartbeats no-idea no-jpake no-md2 no-mdc2 no-rc5 no-rdrand no-rfc3779 no-rsax no-sctp no-seed no-sha0 no-static_engine no-whirlpool no-rc2 no-rc4 no-ssl2 no-ssl3 linux-armv4
make depend
make
cd ..

echo -e "\e[95mBuild DB-4.8.30\e[0m"
if [ -f /usr/share/man/man3/miniupnpc.3.gz ]; then rm /usr/share/man/man3/miniupnpc.3.gz; fi
cd db-4.8.30.NC
cd build_unix
../dist/configure --enable-cxx --disable-shared --disable-replication
make
sudo make install
cd ..
cd ..

echo -e "\e[95mBuild Boost 1_58_0\e[0m"
cd boost_1_58_0
./bootstrap.sh
sudo ./b2 --with-chrono --with-filesystem --with-program_options --with-system --with-thread toolset=gcc variant=release link=static threading=multi runtime-link=static install
cd ..

echo -e "\e[95mBuild miniupnpc 1.9\e[0m"
cd miniupnpc-1.9.20140401
make
sudo make install
cd ..

echo
echo -e "\e[97mDependencies done !\e[0m"
if ! [ -f .pass1 ]
then
touch .pass1
fi
}

function Ok_build {
echo -e "\e[95mBuild OkCash\e[0m"
cd okcash
cd src
make -f makefile.unix OPENSSL_LIB_PATH=/home/pi/bin/openssl-1.0.2l OPENSSL_INCLUDE_PATH=/home/pi/bin/openssl-1.0.2l/include BDB_INCLUDE_PATH=/usr/local/BerkeleyDB.4.8/include/ BDB_LIB_PATH=/usr/local/BerkeleyDB.4.8/lib BOOST_LIB_PATH=/usr/local/lib/ BOOST_INCLUDE_PATH=/usr/local/include/boost/ 
#strip okcashd
sudo cp okcashd /usr/local/bin
}

function conf_ {
if ! [ -f /home/pi/.okcash/okcash.conf ]
then
echo -e "\e[95mInstall okcash.conf\e[0m"
cat <<'EOF'>> /home/pi/.okcash/okcash.conf
#Daemon and listen ON/OFF
daemon=1
listen=1
staking=1

#Connection User and Password
rpcuser=MyUseName
rpcpassword=MyPassword

#Authorized IPs
rpcallowip=127.0.0.1
rpcport=6969
port=6970

#write the location for this blockchain below if not on standard directory
datadir=/home/pi/.okcash

#Add extra Nodes
addnode=180.34.138.133
addnode=150.249.117.19
addonde=99.227.239.19.229

EOF
fi
echo "Done !"
}


echo ""
echo -e "\e[97mOkcash headless builder version $Version\e[0m"
echo -e "\nConfiguration"
echo -e "-------------"
echo -e "Default okcach.conf file    : $DefaultConf"
echo -e "Download Bootstrap.dat      : $Bootstrap"
echo -e "Delete tarballs after build : $CleanAfterInstall"
sleep 5

if ! [ -f .pass1 ]
then
echo -e "\n\e[95mDownload dependencies :\e[0m"
decompress
deps
else
echo ""
echo "Dependencies were already builded..."
echo "Remove .pass1 to restart build..."
echo
sleep 5
fi
sudo ldconfig
Ok_build
killall -9 okcashd || true

if [ $Bootstrap = "YES" ]
then
echo -e "\e[95mRecover Bootstrap.dat :\e[0m"
cd /home/pi
wget -c http://farman-aeromodelisme.fr/hors_site/bootstrap.tar.bz2
tar xvfj bootstrap.tar.bz2
sleep 1
rm /home/pi/bootstrap.tar.bz2
fi

if [ $DefaultConf = "YES" ]; then conf_ ; fi

if [ $CleanAfterInstall = "YES" ]
then
echo -e "\n\e[95mCleaning :\e[0m"
cd /home/pi/bin
rm boost_1_58_0.tar.gz || true
rm openssl-1.0.2l.tar.gz ||true
rm miniupnpc-1.9.20140401.tar.gz || true
rm db-4.8.30.NC.tar.gz || true
echo "Done !!!"
fi

echo -e "\n\e[97mBuild is finished !!!\e[0m"
