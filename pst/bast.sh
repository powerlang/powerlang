#!/bin/bash

here=$(realpath $(dirname $0))

if [ -z $1 ]; then
	echo "Usage: $0 <BSL>"
	exit 1
fi

if [ ! -f $1 ]; then
	echo "$(basename $0): $1: No such file"
	exit 2
fi

target=$($here/vm/config.guess | cut -d '-' -f 1,3)

$here/vm/build/$target/bast $(realpath $1)