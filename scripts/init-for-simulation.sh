

SCRIPT_PATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )"
ROOT_PATH=$SCRIPT_PATH/..

echo $ROOT_PATH
DEFAULT="\e[39m"
RED="\e[91m"
GREEN="\e[92m"
BLUE="\e[94m"
MAGENTA="\e[95m"

# clone pst source code 
cd $ROOT_PATH
if [ ! -f "bootstrap/PST.image" ]; then
	echo -en $BLUE"no pst 'bootstrap from pharo' image, trying to configure one..."$DEFAULT
	"./scripts/init-for-bootstrapping.sh"
	
	if [ $? -ne 0 ]; then
		echo -e $RED"failed!"
		exit
	fi

	echo " done"
fi

cd $ROOT_PATH
cd bootstrap

if [ ! -f "PST-petrich.image" ]; then
	echo -en $GREEN"configuring petrich in pharo..."$DEFAULT
	./pharo PST.image ../scripts/pharo-setup-petrich.st
	if [ $? -ne 0 ]; then
		echo -e $RED"failed!"
		exit
	fi

	echo " done"
fi

if [ -f "gem5/build/POWER/gem5.debug" ]; then
	echo -e $GREEN"gem5 binary found, nothing else to do, quitting!"$DEFAULT
	exit 0
fi	

if [ ! -d "gem5" ]; then
	echo -en $BLUE"no gem5 found in bootstrap dir, trying clone one..."$DEFAULT
	git clone https://gem5.googlesource.com/public/gem5

	if [ $? -ne 0 ]; then
		echo -e $RED"failed!"
		exit
	fi

	echo " done"
fi

# check for boost - bind.hpp. this may only work on debian derivatives, sorry
if [ ! -f "/usr/include/boost/bind.hpp" ]; then
	echo -en $BLUE"boost not found in system, trying install it..."$DEFAULT
    sudo apt-get install libboost-dev

	if [ $? -ne 0 ]; then
		echo -e $RED"failed!"
		exit
	fi

	echo " done"
fi

if [ ! -f "/usr/bin/python-config" ]; then
	sudo apt install python-dev

	if [ $? -ne 0 ]; then
		echo -e $RED"failed!"
		exit
	fi

	echo " done"
fi

cd gem5
scons -j 4 build/POWER/gem5.debug

if [ $? -ne 0 ]; then
	echo -e $RED"build failed!"
	exit
fi

echo -e $GREEN" gem5 correctly built!"


