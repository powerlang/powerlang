#!/bin/bash

here=$(realpath $(dirname $0))

if [ -z $1 ]; then
	echo "Usage: $0 <SCRIPT FILE>"
	exit 1
fi

if [ ! -f $1 ]; then
	echo "$(basename $0): $1: No such file"
	exit 2
fi

"$here/../bootstrap/pharo" \
	"$here/../bootstrap/bootstrap.image" \
	eval \
	"ScriptSegmentBuilder compileScriptFile: '$(realpath $1)'"