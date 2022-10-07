#!/bin/sh

mkdir build
cd build

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
BUILD_TESTING=ON
else
BUILD_TESTING=OFF
fi

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Patch on the fly gz to handle the tests
sed "s|libgz-tools2-backward.so|$PREFIX/lib/libgz-tools2-backward.so|" `which gz` > `which gz`
sed "s|libgz-tools2-backward.dylib|$PREFIX/lib/libgz-tools2-backward.dylib|" `which gz` > `which gz`

cmake ${CMAKE_ARGS} .. \
      -G "Ninja" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON \
      -DBOOST_ROOT=$PREFIX \
      -DBoost_NO_SYSTEM_PATHS=ON \
      -DBoost_NO_BOOST_CMAKE=ON \
      -DBoost_DEBUG=ON \
      -DUSE_EXTERNAL_TINYXML=ON \
      -DUSE_INTERNAL_URDF=OFF \
      -DBUILD_TESTING=$BUILD_TESTING \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      -DRUBY=$BUILD_PREFIX/bin/ruby

cmake --build . --config Release -- -j$CPU_COUNT
cmake --build . --config Release --target install
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
ctest  --output-on-failure -C Release -E "INTEGRATION|PERFORMANCE|REGRESSION"
fi
