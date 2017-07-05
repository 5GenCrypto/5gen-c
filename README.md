# 5gen-c: circuit-based obfuscation

This repository contains files necessary for building and evaluating circuit-based obfuscators.  It contains both a build script, `build.sh`, and a `Dockerfile` for building all the necessary dependencies.  We recommend using `docker` to set up an appropriate environment, although `build.sh` works as well assuming all the dependencies are already installed.

## Building with `docker`

We supply a `Dockerfile` for building the system.  To build, run:

    docker build -t 5gen-c .
    
Then, to run the docker container, run:

    docker run -it 5gen-c /bin/bash
    
Once in the container, run the following to build the code:

    git pull origin master
    ./build.sh
    
If you don't want/need to build `cxs` (which takes a long time), run:

    docker build -t 5gen-c-no-cxs - < Dockerfile-no-cxs

And then to run the container:

    docker run -it 5gen-c-no-cxs /bin/bash
    
Building `5gen-c` is similar to above, except now we don't want to build `cxs`:

    git pull origin master
    ./build.sh --no-cxs
    
## Building with `build.sh`

`build.sh` has several options:

* `--debug` builds the code in debug mode
* `--clean` removes all executables and build files

Running `build.sh` with no options will build everything.

## Running

Once built, there are several scripts available in the main directory for both generating and obfuscating circuits.  In addition, scripts for running the obfuscator on all available circuits can be found in `circ-obfuscation/scripts`.  In particular, `circ-obfuscation/scripts/test.sh` will run the obfuscator on all circuits in `circ-obfuscation/circuits`.
