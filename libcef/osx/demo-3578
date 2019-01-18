#!/usr/bin/env bash

rm -rf cefdemo
mkdir cefdemo 
cd cefdemo

# download
curl http://opensource.spotify.com/cefbuilds/cef_binary_3.3578.1863.gbf8cff2_macosx64.tar.bz2 -o cef_binary.tar.bz2
tar -xf cef_binary.tar.bz2
mv cef_binary_**_macosx64/** ./
rm -rf cef_binary_**_macosx64

mkdir build && cd build
cmake -G "Xcode" ..
