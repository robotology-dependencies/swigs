#!/bin/bash

set -e

swig_versions="1.3.39 1.3.40 2.0.1 2.0.2 2.0.3 2.0.4 2.0.5 2.0.6 2.0.7 2.0.8 2.0.9 2.0.10 2.0.11 2.0.12 3.0.0 3.0.1 3.0.2"

swig_base="$PWD/build/swigs"
mkdir -p $swig_base

if [ ! -e swig ]; then
    git clone --depth=50 https://github.com/swig/swig
    cd swig
else
    cd swig
    git pull https://github.com/swig/swig
fi

echo "Compiling all swig versions"
if [ ! -e swig.spec.in ]; then
    echo "Failed to load swig"
    exit 1
fi

for f in $swig_versions; do
    if [ ! -e $swig_base/$f ] ; then
	echo $f
	git clean -f -d
	git checkout .
	git checkout rel-$f
	./autogen.sh
	./configure --prefix=$swig_base/$f
	make clean
	make
	make install
    fi
done

cd $swig_base/..
rm -f swigs.zip
zip -r swigs swigs
