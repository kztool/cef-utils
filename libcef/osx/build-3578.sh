#!/usr/bin/env bash

brew install cmake

rm -rf libcef
mkdir libcef 
cd libcef

# download
curl http://opensource.spotify.com/cefbuilds/cef_binary_3.3578.1863.gbf8cff2_macosx64.tar.bz2 -o cef_binary.tar.bz2
tar -xf cef_binary.tar.bz2

# build
cd cef_binary_**_macosx64
mkdir build 
cd build

cmake -G "Xcode" ..
for CONFIG in Debug Release
do
xcodebuild -target ALL_BUILD -configuration ${CONFIG} build
cp -r ../${CONFIG} ../../
cp ./libcef_dll_wrapper/${CONFIG}/libcef_dll_wrapper.a ../../${CONFIG}/
done
cp -r ../include ../../

# clean up
cd ../../
rm -rf cef_binary.tar.bz2
rm -rf cef_binary_**_macosx64
