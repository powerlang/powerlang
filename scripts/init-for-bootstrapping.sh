
SCRIPT_PATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )"
ROOT_PATH=$SCRIPT_PATH/..

DEFAULT="\e[39m"
RED="\e[91m"
GREEN="\e[92m"
BLUE="\e[94m"
MAGENTA="\e[95m"

# clone pst source code 
cd $ROOT_PATH
mkdir -p src
cd src
if [ ! -d "kernel" ]
then
	echo -e ""
	echo -e $GREEN"cloning Power Smalltalk kernel repository..."$DEFAULT
	git clone git@github.com:melkyades/kernel.git
	echo ""
fi

# setup a pharo image for bootstrapping
cd $ROOT_PATH
mkdir -p bootstrap
cd bootstrap
if [ ! -f "Pharo.image" ]
then
	echo -e $GREEN"fetching pharo 7..."$DEFAULT
	curl https://get.pharo.org/70+vm | bash 
	echo ""
fi

if [ ! -f "PST.image" ]; then
	echo -en $GREEN"configuring pharo for Power Smalltalk development..."$DEFAULT
	./pharo Pharo.image ../scripts/pharo-setup-image.st
	echo " done"
fi

if [ $? -eq 0 ]; then
	echo -e $MAGENTA
	echo "bootstrap pharo has been built, you can now open the development environment:"
	echo -e $BLUE
	echo "> cd bootstrap"
	echo "> ./pharo-ui PST.image"
	echo -e $MAGENTA
	echo "there is a playground open ready to help you"
	echo ""
else
	echo ""
	echo -e $RED"there was some error"
fi


