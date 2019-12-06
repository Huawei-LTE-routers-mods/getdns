#!/bin/bash
set -e

export PATH="/home/valdikss/mobile-modem-router/e5372/kernel/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi/bin:$PATH"
# Set your OpenSSL path here
OPENSSL_PATH="/home/valdikss/mobile-modem-router/openssl/git/openssl"

mkdir -p installed/huawei/{vfp3,novfp} || true


# Balong Hi6921 V7R11 (E3372h, E5770, E5577, E5573, E8372, E8378, etc) and Hi6930 V7R2 (E3372s, E5373, E5377, E5786, etc)
# softfp, vfpv3-d16 FPU
export CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -O2 -s"
export PKG_CONFIG_PATH="$OPENSSL_PATH/installed/huawei/vfp3/lib/pkgconfig/"
# -I/home/valdikss/mobile-modem-router/openssl/openssl-1.0.2p/installed_e5770/etc/ssl/include/ -L/home/valdikss/mobile-modem-router/openssl/openssl-1.0.2p/installed_e5770/etc/ssl/lib -I/home/valdikss/mobile-modem-router/openvpn/lzo/lzo-2.10/i/e5770_lzo/usr/local/include -L/home/valdikss/mobile-modem-router/openvpn/lzo/lzo-2.10/i/e5770_lzo/usr/local/lib"
(git clone https://github.com/yaml/libyaml.git && cd libyaml && git checkout 0.2.2 && autoreconf -vif) || true
cd libyaml
make clean || true
./configure --host=arm-linux-gnueabi --prefix="$PWD/installed/huawei/vfp3" --disable-shared
make "$@"
make install
cd ..

make clean || true
./configure --host=arm-linux-gnueabi --disable-shared --enable-stub-only --with-stubby \
 --with-ssl="$OPENSSL_PATH/installed/huawei/vfp3" \
 --with-libyaml="$PWD/libyaml/installed/huawei/vfp3" \
 --prefix="" \
 --without-libidn --without-libidn2 --without-libbsd --without-bsd
make "$@"
make install DESTDIR="$PWD/installed/huawei/vfp3"

arm-linux-gnueabi-strip -s installed/huawei/vfp3/bin/stubby
patchelf --set-interpreter /system/lib/glibc/ld-linux.so.3 installed/huawei/vfp3/bin/stubby

# Balong Hi6920 V7R1 (E3272, E3276, E5372, etc)
# soft, novfp
export CFLAGS="-march=armv7-a -mfloat-abi=soft -mthumb -O2 -s"
export PKG_CONFIG_PATH="$OPENSSL_PATH/installed/huawei/novfp/lib/pkgconfig/"
cd libyaml
make clean || true
./configure --host=arm-linux-gnueabi --prefix="$PWD/installed/huawei/novfp" --disable-shared
make "$@"
make install
cd ..

make clean || true
./configure --host=arm-linux-gnueabi --disable-shared --enable-stub-only --with-stubby \
 --with-ssl="$OPENSSL_PATH/installed/huawei/novfp" \
 --with-libyaml="$PWD/libyaml/installed/huawei/novfp" \
 --prefix="" \
 --without-libidn --without-libidn2 --without-libbsd --without-bsd
make "$@"

make install DESTDIR="$PWD/installed/huawei/novfp"

arm-linux-gnueabi-strip -s installed/huawei/novfp/bin/stubby
patchelf --set-interpreter /system/lib/glibc/ld-linux.so.3 installed/huawei/novfp/bin/stubby
