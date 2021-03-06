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

> This might be a bit incomplete, google around as the errors come up and PR or open an issue!

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

```bash
# This is in ./configure-postgres.sh
export CC=clang
export PG_SYSROOT=$(pwd)/wasi-libc/sysroot
cd postgres
./configure
```

Now let's start building postgres. We can do this by jumping into the `postgres/src` directory and
running...

```bash
export COPT="--target=wasm32-unknown-wasi --sysroot=$(pwd)/../../wasi-libc/sysroot"
make
```

### 3. Show Stopper - No netdb.h

Here's our first show-stopper. The wasi-libc lacks networking headers!

```
make[1]: Entering directory '/home/seve/workspace/os/wasm-postgres/postgres/src/port'
clang -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -Wno-unused-command-line-argument -O2 --target=wasm32-unknown-wasi --sysroot=/home/seve/workspace/os/wasm-postgres/postgres/src/../../wasi-libc/sysroot -I../../src/port -DFRONTEND -I../../src/include  -D_GNU_SOURCE   -c -o path.o path.c
In file included from path.c:19:
In file included from ../../src/include/postgres_fe.h:25:
In file included from ../../src/include/c.h:1355:
../../src/include/port.h:17:10: fatal error: 'netdb.h' file not found
#include <netdb.h>
         ^~~~~~~~~
1 error generated.
make[1]: *** [<builtin>: path.o] Error 1
make[1]: Leaving directory '/home/seve/workspace/os/wasm-postgres/postgres/src/port'
make: *** [Makefile:42: all-port-recurse] Error 2
```

* [unable to compile simple httpclient wasm module](https://github.com/WebAssembly/wasi-libc/issues/18)