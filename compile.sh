#!/bin/bash

set -e

swig_base="$PWD/build/swigs"
mkdir -p $swig_base

if [ ! -e swig ]; then
    git clone https://github.com/swig/swig
    cd swig
else
    cd swig
    git fetch --prune
    git reset --hard origin/master
fi

if [ ! -e swig.spec.in ]; then
    echo "Failed to load swig"
    exit 1
fi


default_swig_versions="$(git for-each-ref --format="%(refname)" refs/tags/rel-*.*.* | sed 's|refs/tags/rel-||' | sort -V | grep -v "1.3.32\|1.3.33\|1.3.34\|1.3.35\|1.3.36\|beta")"

if [ -z "$SWIG_VERSIONS" ]; then
    swig_versions="$default_swig_versions"
    echo "Compiling all swig versions"
else
    swig_versions="$SWIG_VERSIONS"
    echo "Compiling swig versions: $swig_versions"
fi

for f in $swig_versions; do
    if [ ! -e $swig_base/$f ] ; then
        echo "Building swig version $f in $swig_base/$f"
        echo $f
        git clean -f -d
        git checkout .
        git checkout rel-$f
        ./autogen.sh
        ./configure --prefix=$swig_base/$f
        make clean || true
        make
        make install
    else
        echo "swig version $f already built in $swig_base/$f"
    fi
done

cd $swig_base/..
rm -f swigs.zip
for f in $swig_versions; do
    echo "adding swig version $f to the archive"
    zip -qr swigs.zip swigs/$f
done
