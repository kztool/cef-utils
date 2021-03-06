SRCROOT="$( cd "$( dirname "$0" )" && pwd  )"
LIBPATH=${SRCROOT}"/libs"
CEFPATH=${LIBPATH}"/cef"

if ! [ -x "$(command -v brew)" ]; then
    echo 'Error: brew is not installed.' >&2
    exit 1
fi

if ! [ -x "$(command -v cmake)" ]; then
    brew install cmake
fi

if [ ! -d ${LIBPATH} ]; then
    mkdir -p ${LIBPATH}
fi

# install libcef
if [ ! -d ${CEFPATH} ]; then
    mkdir -p ${CEFPATH}
    cd ${CEFPATH}

    # download
    curl http://opensource.spotify.com/cefbuilds/cef_binary_3.3578.1867.g0f6d65a_macosx64.tar.bz2 -o cef_binary.tar.bz2
    tar -xf cef_binary.tar.bz2

    # build
    cd cef_binary_**_macosx64
    mkdir build
    cd build
    cmake -G "Xcode" ..
    cp -r ../include ../../

    for CONFIG in Debug Release
do
    xcodebuild -target ALL_BUILD -configuration ${CONFIG} build
    cp -r ../${CONFIG} ../../
    cp ./libcef_dll_wrapper/${CONFIG}/libcef_dll_wrapper.a ../../${CONFIG}/
done

    # clean up
    cd ../../
    rm -rf cef_binary.tar.bz2
fi
