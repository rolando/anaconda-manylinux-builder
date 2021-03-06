#!/bin/bash
#
# This script builds manylinux builds. It is expected to run on official manylinux docker images.
#
# Environment variables are the same as for build-wheels.sh and additionally the following:
# - PYTHON_PREFIXES : list of python environments in the docker image, default to all available.
#
set -ex
if [ -f $WORKDIR/build-setup.sh ]; then
  # Load customizations.
  source $WORKDIR/build-setup.sh
fi
set -u

PYTHON_PREFIXES=${PYTHON_PREFIXES:-"/opt/python/*"}
# Expand glob.
PYTHON_PREFIXES=$(eval echo $PYTHON_PREFIXES)

# Build wheels for each python env.
for PREFIX in $PYTHON_PREFIXES; do
  PATH=$PREFIX/bin:$PATH $WORKDIR/scripts/build-wheels.sh
done

# Bundle external shared libraries to non-pure python wheels.
TARGET_WHEELS=$(ls -1 $WHEELHOUSE/*.whl | grep -v -- -none- | grep -v manylinux)
for WHL in $TARGET_WHEELS; do
  auditwheel repair "$WHL" -w $WHEELHOUSE
  # Remove original wheel to not pollute repository with non-manylinux
  # packages.
  rm -f $WHL
done
