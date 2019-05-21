
SCRIPT_PATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )"
ROOT_PATH=$SCRIPT_PATH/..

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
  git clone git@github.com:melkyades/kernel.git
fi

# setup a pharo image for bootstrapping
cd $ROOT_PATH
mkdir -p bootstrap
cd bootstrap
if [ ! -f "Pharo.image" ]
then
  curl https://get.pharo.org/70+vm | bash 
fi

./pharo Pharo.image ../scripts/pharo-setup-image.st

if [ $? -eq 0 ]; then
	echo -e $GREEN
	echo "bootstrap image has been built, you can now open the development environment with:"
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


