#! /bin/sh

set -e

ZIPFILE=asf-standalone-archive-3.32.0.48.zip
ZIPFILE_URL=http://www.atmel.com/images/$ZIPFILE
ASF_DIR=xdk-asf-3.32.0
PATCHFILE=xdk-asf-3.32.0_fixes.patch

if [ ! -f $ZIPFILE ] ; then
    echo "Downloading $ZIPFILE_URL ..."
    wget $ZIPFILE_URL
fi

echo "Removing stale ASF_DIR ..."
rm -rf $ASF_DIR

echo "Unzipping fresh ASF_DIR ..."
unzip -q $ZIPFILE

echo "File count before pruning ..."
find $ASF_DIR -type f | wc -l

# The patch replaces an 'asm' statement by an '__asm__' statement, which allows the code
# to be compiled using standard C without GNU extensions.

echo "Patching ASF_DIR ..."
patch -p0 < $PATCHFILE

echo "Removing superfluous toplevel directories ..."
rm -rf $ASF_DIR/avr32
rm -rf $ASF_DIR/mega
rm -rf $ASF_DIR/xmega
rm -rf $ASF_DIR/sam0

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
    rm -rf `find $ASF_DIR -type d -name $rd`
done

echo "File count after pruning ..."
find $ASF_DIR -type f | wc -l
