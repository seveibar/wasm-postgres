# WASM Postgres

An attempt to build postgres server to wasm so that it can be
run in browsers or cloudflare workers.

## Why?

* Embedded postgres anywhere where WebAssembly is supported.
* SQLite has incredible in-memory test fixtures, let's get those with postgres in NodeJS and Python!
* Cloudflare Workers could run postgres server and provide ultra-cheap 50MB databases

## How to Port

If you haven't compiled C to wasm before, check out this very
simple example:

```c
#include <stdio.h>

int main(void)
{
    puts("Hello");
    return 0;
}
```

We can build this to wasm using...

```
clang --target=wasm32-unknown-wasi --sysroot $(pwd)/wasi-libc/sysroot -O2 -s -o test.wasm test.c
```

We can now run our wasm code, it's that simple!

```
$ wasmer test.wasm
Hello
```

Porting is just configuring the postgres Makefile to have our `--target` and `--sysroot`, then
fixing any compiler errors by introducing shims.

## Getting Started

## 0. Installing Stuff

> This might be a bit incomplete, google around as the errors come up and PR or open and issue!

> TODO why not just shove all this into a Dockerfile

You'll need a bunch of things this is what I installed on Arch Linux via `yay`:

```
wasi-sdk-bin
wasm-ld
clang
llvm
lld
```


### 1. Building sysroot

You'll need to configure your system a little bit. Let's start with `wasm32-libc`, `wasm-32libc`
provides a system root with implementations of common C header files. Basically this is your
`/usr/include` directory, but specifically made for wasm!

```
cd wasi-libc
make
```

You now have a sysroot at `wasi-libc/sysroot`

### 2. Configure postgres for WASM building

Before we `make` postgres, we run the `configure` script to configure our Makefile. We'll want
to set a couple things in our environment to make sure postgres is configured with WASM as it's
target...

