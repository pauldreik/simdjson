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

variant=ossfuzz-noavx8
if [ ! -d build-$variant ] ; then

  export CC=clang-8
  export CXX="clang++-8"
  export CFLAGS="-fsanitize=fuzzer-no-link,address -fno-sanitize-recover=undefined -mno-avx2 -mno-avx "
  export CXXFLAGS="-fsanitize=fuzzer-no-link,address -fno-sanitize-recover=undefined -mno-avx2 -mno-avx"
  export LIB_FUZZING_ENGINE="-fsanitize=fuzzer"

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

variant=ossfuzz-withavx
if [ ! -d build-$variant ] ; then

  export CC=clang
  export CXX="clang++"
  export CFLAGS="-fsanitize=fuzzer-no-link,address -fno-sanitize-recover=undefined"
  export CXXFLAGS="-fsanitize=fuzzer-no-link,address -fno-sanitize-recover=undefined"
  export LIB_FUZZING_ENGINE="-fsanitize=fuzzer"

  mkdir build-$variant
  cd build-$variant

  cmake .. \
	-GNinja \
	-DCMAKE_BUILD_TYPE=Debug \
	-DSIMDJSON_BUILD_STATIC=On \
	-DENABLE_FUZZING=On \
	-DSIMDJSON_FUZZ_LINKMAIN=Off \
	-DSIMDJSON_FUZZ_LDFLAGS=$LIB_FUZZING_ENGINE

  ninja

  cd ..
fi

variant=ossfuzz-msan-noavx8
if [ ! -d build-$variant ] ; then

  export CC=clang-8
  export CXX="clang++-8"
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

variant=ossfuzz-msan-withavx8
if [ ! -d build-$variant ] ; then

  export CC=clang-8
  export CXX="clang++-8"
  export CFLAGS="-fsanitize=fuzzer-no-link,memory"
  export CXXFLAGS="-fsanitize=fuzzer-no-link,memory"
  export LIB_FUZZING_ENGINE="-fsanitize=fuzzer,memory"

  mkdir build-$variant
  cd build-$variant

  cmake .. \
	-GNinja \
	-DCMAKE_BUILD_TYPE=Debug \
	-DSIMDJSON_BUILD_STATIC=On \
	-DENABLE_FUZZING=On \
	-DSIMDJSON_FUZZ_LINKMAIN=Off \
	-DSIMDJSON_FUZZ_LDFLAGS=$LIB_FUZZING_ENGINE 

  ninja

  cd ..
fi


variant=ossfuzz-fast8
if [ ! -d build-$variant ] ; then

  export CC=clang-8
  export CXX="clang++-8"
  export CFLAGS="-fsanitize=fuzzer-no-link -O3 -g"
  export CXXFLAGS="-fsanitize=fuzzer-no-link -O3 -g"
  export LIB_FUZZING_ENGINE="-fsanitize=fuzzer"

  mkdir build-$variant
  cd build-$variant

  cmake .. \
	-GNinja \
	-DCMAKE_BUILD_TYPE= \
	-DSIMDJSON_BUILD_STATIC=On \
	-DENABLE_FUZZING=On \
	-DSIMDJSON_FUZZ_LINKMAIN=Off \
	-DSIMDJSON_FUZZ_LDFLAGS=$LIB_FUZZING_ENGINE

  ninja

  cd ..
fi


