#!/bin/bash
DIR_NAME="day$1"
TEMPLATE_FILE="$(pwd)/$(dirname $0)/template.zig"
if [ ! -d "$DIR_NAME" ]; then
	mkdir $DIR_NAME
	cd $DIR_NAME
	zig init-exe
	sed -i '/const exe = /a \    exe.addPackagePath("utils", "../shared/utils.zig");' build.zig
	cp $TEMPLATE_FILE ./src/main.zig
	touch input.txt
else
	echo "$DIR_NAME already exists"
fi
