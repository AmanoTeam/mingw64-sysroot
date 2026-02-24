#!/bin/bash

set -eu

declare -r sysroot_directory="/tmp/${CROSS_COMPILE_TRIPLET}"

declare extra_flags=''

git clone https://git.code.sf.net/p/mingw-w64/mingw-w64
mkdir mingw-w64/build
cd mingw-w64/build

if [ "${CROSS_COMPILE_TRIPLET}" = 'x86_64-w64-mingw32' ]; then
	extra_flags+=' --disable-lib32'
fi

../configure \
	--with-default-msvcrt='msvcrt' \
	--with-default-win32-winnt='0x0501' \
	--host="${CROSS_COMPILE_TRIPLET}" \
	--prefix="${sysroot_directory}" \
	--with-sysroot="${sysroot_directory}" \
	${extra_flags}

make install

../mingw-w64-libraries/winpthreads/configure \
	--host="${CROSS_COMPILE_TRIPLET}" \
	--prefix="${sysroot_directory}"

make install

../mingw-w64-libraries/winstorecompat/configure \
	--host="${CROSS_COMPILE_TRIPLET}" \
	--prefix="${sysroot_directory}"

make install

../mingw-w64-libraries/libmangle/configure \
	--host="${CROSS_COMPILE_TRIPLET}" \
	--prefix="${sysroot_directory}"

make install

declare tarball_filename="/tmp/${CROSS_COMPILE_TRIPLET}.tar.xz"

if [ "${CROSS_COMPILE_TRIPLET}" != 'aarch64-w64-mingw32' ]; then
	mv "${sysroot_directory}/bin/lib"*'.dll' "${sysroot_directory}/lib"
fi

tar --directory='/tmp' --create --file=- "${CROSS_COMPILE_TRIPLET}" | xz --threads='0' --compress -9 > "${tarball_filename}"
sha256sum "${tarball_filename}" | sed 's|/tmp/||' > "${tarball_filename}.sha256"
