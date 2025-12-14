#!/bin/bash

set -eu

declare -r sysroot_tarball='/tmp/sysroot.tar.zst'
declare -r sysroot_directory='/tmp/usr'

declare -ra targets=(
	'x86_64-w64-mingw32'
	'i686-w64-mingw32'
	'aarch64-w64-mingw32'
)

curl \
	--url 'https://archlinux.org/packages/extra/any/mingw-w64-crt/download/' \
	--retry '30' \
	--retry-delay '0' \
	--retry-all-errors \
	--retry-max-time '0' \
	--location \
	--silent \
	--output "${sysroot_tarball}"

tar \
	--directory="$(dirname "${sysroot_directory}")" \
	--extract \
	--file="${sysroot_tarball}"

curl \
	--url 'https://archlinux.org/packages/extra/any/mingw-w64-headers/download/' \
	--retry '30' \
	--retry-delay '0' \
	--retry-all-errors \
	--retry-max-time '0' \
	--location \
	--silent \
	--output "${sysroot_tarball}"

tar \
	--directory="$(dirname "${sysroot_directory}")" \
	--extract \
	--file="${sysroot_tarball}"

curl \
	--url 'https://archlinux.org/packages/extra/any/mingw-w64-winpthreads/download/' \
	--retry '30' \
	--retry-delay '0' \
	--retry-all-errors \
	--retry-max-time '0' \
	--location \
	--silent \
	--output "${sysroot_tarball}"

tar \
	--directory="$(dirname "${sysroot_directory}")" \
	--extract \
	--file="${sysroot_tarball}"

curl \
	--url 'https://github.com/Windows-on-ARM-Experiments/mingw-woarm64-build/releases/latest/download/aarch64-w64-mingw32-msvcrt-toolchain.tar.gz' \
	--retry '30' \
	--retry-delay '0' \
	--retry-all-errors \
	--retry-max-time '0' \
	--location \
	--silent \
	--output "${sysroot_tarball}"

tar \
	--directory="$(dirname "${sysroot_directory}")" \
	--extract \
	--file="${sysroot_tarball}"

unlink  "$(dirname "${sysroot_directory}")/aarch64-w64-mingw32/include/zconf.h"
unlink  "$(dirname "${sysroot_directory}")/aarch64-w64-mingw32/include/zlib.h"

rm  \
	--recursive \
	"$(dirname "${sysroot_directory}")/aarch64-w64-mingw32/lib/libz."* \
	"$(dirname "${sysroot_directory}")/aarch64-w64-mingw32/lib/pkgconfig"

for triplet in "${targets[@]}"; do
	declare tarball_filename="/tmp/${triplet}.tar.xz"
	tar --directory="${sysroot_directory}" --create --file=- "${triplet}" | xz --threads='0' --compress -9 > "${tarball_filename}"
	sha256sum "${tarball_filename}" | sed 's|/tmp/||' > "${tarball_filename}.sha256"
done
