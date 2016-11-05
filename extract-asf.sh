#! /bin/sh

set -e

ZIPFILE=asf-standalone-archive-3.32.0.48.zip
ZIPFILE_URL=http://www.atmel.com/images/$ZIPFILE
XDK_ASF_DIR=xdk-asf-3.32.0
PATCHFILE=xdk-asf-3.32.0_fixes.patch

if [ ! -f $ZIPFILE ] ; then
    echo "Downloading $ZIPFILE_URL ..."
    wget $ZIPFILE_URL
fi

echo "Removing stale XDK_ASF_DIR ..."
rm -rf $XDK_ASF_DIR

echo "Unzipping fresh XDK_ASF_DIR ..."
unzip -q $ZIPFILE

echo "File count before pruning ..."
find $XDK_ASF_DIR -type f | wc -l

echo "Patching XDK_ASF_DIR ..."
patch -p0 < $PATCHFILE

echo "Removing superfluous toplevel directories ..."
rm -rf $XDK_ASF_DIR/avr32
rm -rf $XDK_ASF_DIR/mega
rm -rf $XDK_ASF_DIR/xmega
rm -rf $XDK_ASF_DIR/sam0

echo "Removing unused subdirectories ..."
REMOVE_DIRS="
    iar
    doxygen
    at32*
    atmega*
    atxmega*
    xmega*
    sam3*
    samd20*
    samd21*
    sam4[clns]*
    sam[bcdglrs]*
    "
for rd in $REMOVE_DIRS
do
    rm -rf `find $XDK_ASF_DIR -type d -name $rd`
done

echo "File count after pruning ..."
find $XDK_ASF_DIR -type f | wc -l
