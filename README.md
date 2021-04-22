AI Deployment Framework
=======================

Summary
-------


Installation
------------

Some dependent libraries are included as git submodules.
These can be obtained by cloning this repository with the following commands:
```shell
git clone git@github.com:xmos/adf.git
cd adf
make submodule_update
```

Install at least version 15 of the XMOS tools from your preferred location and activate it by sourcing `SetEnv` in the installation root.

[CMake 3.14](https://cmake.org/download/) or newer is required for building libraries and test firmware.
A correct version of CMake (and `make`) is included in the [`environment.yml`](environment.yml) Conda environment file.
To set up and activate the environment, simply run:
```shell
conda env create -p ./adf_venv -f environment.yml
conda activate adf_venv/
```

Build the libraries with default settings (see the [`Makefile`](Makefile) for more), run:
```shell
make build
```

Install the `xcore_interpreters` python package using `pip` (preferably inside a venv):
```shell
pip install -e "./xcore_interpreters"
```

Running Tests
-------------

Before running any tests, install the test dependencies using:
```shell
pip install -e "./xcore_interpreters[test]"
```

To run all tests, execute:
```shell
make test
```
For more granular testing, consult the [`Makefile`](Makefile).

Docker Image
------------

The Dockerfile provided is used in the CI system but can serve as a guide to system setup.
Installation of the XMOS tools requires connection to our network.
```shell
docker build -t xmos/adf .
docker run -it \
    -v $(pwd):/ws \
    -u $(id -u):$(id -g)  \
    -w /ws  \
    xmos/adf \
    bash -l
```

Note that this container will stop when you exit the shell.
For a persistent container:
 - add `-d` to the docker run command to start detached;
 - add `--name somename`;
 - enter with `docker exec -it somename bash -l`;
 - stop with `docker stop somename`.

Then inside the container
```shell
# setup environment
conda env create -p adf_venv -f environment.yml
/XMOS/get_tools.py 15.0.5
conda activate ./adf_venv
pip install -e "./xcore_interpreters[test]"
# activate tools (each new shell)
module load tools/15.0.5
# build all and run tests
make build test
```
