#!/bin/sh
#
# this file is not meant to be merged, just used during developement to avoid
# having to do the full clone/docker/init step for debugging the cmake conf

set -eu

variant=plain-noavx
if [ ! -d build-$variant ] ; then
mkdir build-$variant
cd build-$variant

cmake .. \
-GNinja \
-DCMAKE_BUILD_TYPE=Debug \
-DSIMDJSON_BUILD_STATIC=On \
-DENABLE_FUZZING=On \
-DSIMDJSON_FUZZ_LINKMAIN=On \
-DSIMDJSON_DISABLE_AVX=On

ninja

cd ..
fi

variant=plain-normal
if [ ! -d build-$variant ] ; then
mkdir build-$variant
cd build-$variant

cmake .. \
-GNinja \
-DCMAKE_BUILD_TYPE=Debug \
-DSIMDJSON_BUILD_STATIC=On \
-DENABLE_FUZZING=On \
-DSIMDJSON_FUZZ_LINKMAIN=On \

ninja

cd ..
fi

variant=ossfuzz-noavx
if [ ! -d build-$variant ] ; then

export CC=clang
export CXX="clang++"
export CFLAGS="-fsanitize=fuzzer-no-link,address -fno-sanitize-recover=undefined -mno-avx2 -mno-avx "
export CXXFLAGS="-fsanitize=fuzzer-no-link,address -fno-sanitize-recover=undefined -mno-avx2 -mno-avx"
export LIB_FUZZING_ENGINE="-fsanitize=fuzzer"

mkdir build-ossfuzz-noavx
cd build-ossfuzz-noavx

cmake .. \
-GNinja \
-DCMAKE_BUILD_TYPE=Debug \
-DSIMDJSON_BUILD_STATIC=On \
-DENABLE_FUZZING=On \
-DSIMDJSON_FUZZ_LINKMAIN=Off \
-DSIMDJSON_FUZZ_LDFLAGS=$LIB_FUZZING_ENGINE \
      -DSIMDJSON_DISABLE_AVX=On

ninja

cd ..
fi

variant=ossfuzz-msan
if [ ! -d build-$variant ] ; then

export CC=clang-7
export CXX="clang++-7"
export CFLAGS="-fsanitize=fuzzer-no-link,memory -mno-avx2 -mno-avx "
export CXXFLAGS="-fsanitize=fuzzer-no-link,memory -mno-avx2 -mno-avx"
export LIB_FUZZING_ENGINE="-fsanitize=fuzzer,memory"

mkdir build-$variant
cd build-$variant

cmake .. \
-GNinja \
-DCMAKE_BUILD_TYPE=Debug \
-DSIMDJSON_BUILD_STATIC=On \
-DENABLE_FUZZING=On \
-DSIMDJSON_FUZZ_LINKMAIN=Off \
-DSIMDJSON_FUZZ_LDFLAGS=$LIB_FUZZING_ENGINE \
      -DSIMDJSON_DISABLE_AVX=On

ninja

cd ..
fi

