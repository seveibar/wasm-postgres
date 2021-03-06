export CC=clang
export PG_SYSROOT=$(pwd)/wasi-libc/sysroot
cd postgres
./configure