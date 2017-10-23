#!/bin/bash
set -e
Bootstrap=NO
Version=1.2

function decompress {
echo -e "\e[95mDecompress boost...\e[0m"
if ! [ -d /home/pi/bin/boost_1_58_0 ]
then
wget -c http://farman-aeromodelisme.fr/hors_site/okcash/boost_1_58_0.tar.gz
tar xvfz boost_1_58_0.tar.gz
fi
sudo apt-get update
sudo apt-get install libbz2-dev liblzma-dev libzip-dev zlib1g-dev python-dev -y
echo

echo -e "\e[95mDecompress openssl...\e[0m"
if ! [ -d /home/pi/bin/openssl-1.0.2l ]
then
wget -c http://farman-aeromodelisme.fr/hors_site/okcash/openssl-1.0.2l.tar.gz
tar xvfz openssl-1.0.2l.tar.gz
fi
echo

echo -e "\e[95mDecompress miniupnpc...\e[0m"
if ! [ -d /home/pi/bin/miniupnpc-1.9.20140401 ]
then
wget -c http://farman-aeromodelisme.fr/hors_site/okcash/miniupnpc-1.9.20140401.tar.gz
tar xvfz miniupnpc-1.9.20140401.tar.gz
fi
echo

echo -e "\e[95mDecompress db-4.8.30...\e[0m"
if ! [ -d /home/pi/bin/db-4.8.30.NC ]
then
wget -c http://farman-aeromodelisme.fr/hors_site/okcash/db-4.8.30.NC.tar.gz
tar xvfz db-4.8.30.NC.tar.gz
fi
echo

echo -e "\e[95mDecompress okcash...\e[0m"
if ! [ -d /home/pi/bin/okcash ]
then
git clone https://github.com/okcashpro/okcash.git || true
else
cd /home/pi/bin/okcash
git pull
cd /home/pi/bin
fi
echo

}

function deps {
echo -e "\e[95mBuild Openssl\e[0m"
cd openssl-1.0.2l
./Configure no-zlib no-shared no-dso no-krb5 no-camellia no-capieng no-cast no-dtls1 no-gost no-gmp no-heartbeats no-idea no-jpake no-md2 no-mdc2 no-rc5 no-rdrand no-rfc3779 no-rsax no-sctp no-seed no-sha0 no-static_engine no-whirlpool no-rc2 no-rc4 no-ssl2 no-ssl3 linux-armv4
make depend
make
cd ..
echo ""

echo -e "\e[95mBuild DB-4.8.30\e[0m"
cd db-4.8.30.NC
cd build_unix
../dist/configure --enable-cxx --disable-shared --disable-replication
make
sudo make install
cd ..
cd ..
echo

echo -e "\e[95mBuild Boost 1_58_0\e[0m"
cd boost_1_58_0
./bootstrap.sh
sudo ./b2 --with-chrono --with-filesystem --with-program_options --with-system --with-thread toolset=gcc variant=release link=static threading=multi runtime-link=static install
cd ..
echo

echo -e "\e[95mBuild miniupnpc 1.9\e[0m"
cd miniupnpc-1.9.20140401
make
sudo make install
cd ..
echo
echo -e "\e[95mDependencies done !\e[0m"
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
echo
}

echo -e "\n\e[97mOkcash headless builder version $Version\e[0m"
echo ""
if ! [ -f .pass1 ]
then
echo -e "\e[95mBuild Dependencies :\e[0m"
echo ""
decompress
deps
else
echo "Dependencies were already builded..."
echo "Remove .pass1 to restart their build..."
sleep 5
fi
echo ""
sudo ldconfig
Ok_build
killall -9 okcashd || true

if [ $Bootstrap = "YES" ]
then
echo ""
echo -e "\e[95mRecover Bootstrap.dat :\e[0m"
cd /home/pi
wget -c http://farman-aeromodelisme.fr/hors_site/bootstrap.tar.bz2
tar xvfj bootstrap.tar.bz2
fi

echo -e "\n\e[97mBuild is finished !!!\e[0m"

