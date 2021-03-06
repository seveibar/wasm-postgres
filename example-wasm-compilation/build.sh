clang --target=wasm32-unknown-wasi --sysroot $(pwd)/../wasi-libc/sysroot -O2 -s -o test.wasm test.c
