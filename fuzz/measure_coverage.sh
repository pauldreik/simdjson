#!/bin/sh
#
# make a coverage build

bdir=build-coverage
if [ ! -d $bdir ] ; then
    mkdir -p $bdir
    cd $bdir

    export CC=gcc
    export CXX="g++"
    export CFLAGS="-fprofile-arcs -ftest-coverage"
    export CXXFLAGS="-fprofile-arcs -ftest-coverage"
    export LDFLAGS="-fprofile-arcs -ftest-coverage"

    cmake .. \
          -GNinja \
          -DCMAKE_BUILD_TYPE=Debug \
          -DSIMDJSON_BUILD_STATIC=On \
          -DENABLE_FUZZING=On \
	  -DSIMDJSON_FUZZ_LINKMAIN=On
    ninja
    cd ..
fi

# run the fuzzers as normal, then run
#cd build-coverage
#gcovr -r . --html --html-details --sort-uncovered -o out.html
# and view the results in out.html
'
