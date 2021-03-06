==========================
Anaconda-Manylinux builder
==========================

This repository contains scripts that helps building manylinux wheels and
upload them to `Anaconda.org`_. `Anaconda.org`_ allows you to host `Conda`_
packages as well other packages types like wheels. By default builds Manylinux
wheels for Python 3.5 and Python 3.6.

**How does it work?** We use `Travis CI`_ to build `Manylinux`_ wheels and
upload them to `Anaconda.org`_.

**Why wheels?** Wheels is a convenient format for fast and offline deployments. If
you are not convinced, watch this great presentation: `Shipping Software to Users
With Python <https://www.youtube.com/watch?v=5BqAeN-F9Qs>`_

**Why Anaconda.org?** I'm a fan of `Conda`_ but in my day to day work the
deployment is done via standard python packaging tools (that is ``pip``).
Hosting wheels in `Anaconda.org`_ is very convenient to distribute wheels for
specific packages versions to developers and build systems. The alternative is
to build a static index and host it somewhere (i.e. S3).

How to use this repository
==========================

In order to upload packages to `Anaconda.org`_ you need to create an account
and use the ``anaconda-client`` package which is available via the `Conda`_
package manager.

Once you have an account and the ``anaconda-client`` package installed, run the
following command::

  anaconda auth --create scopes 'api:write pypi:upload' -n travis-upload

Follow the instructions and copy the token which looks like ``ab-0a2c3d4d-a4d4d4d4``.

Setting up your repository
--------------------------

1. Fork this repository.
2. Enable `Travis CI`_ for your repository.
3. Edit the settings for your project in `Travis CI`_ and add the secure
   variables ``ANACONDA_TOKEN`` and ``ANACONDA_USER`` with your authorization
   token and `Anaconda.org`_ username, respectively.
4. Disable builds for pull requests. Unless you want anybody to
   publish packages to your account.
  

Building packages
-----------------
1. Create a branch. The branch name will be used as a label in `Anaconda.org`_.
2. Update the ``requirements.txt`` file. Optionally, update the
   ``requirements-build.txt`` file.
3. Push your branch.

After a few minutes, your packages will be uploaded to your `Anaconda.org`_
account: ``https://anaconda.org/<username>``.

Installing the packages
-----------------------

You can use the following command to install packages from `Anaconda.org`_::

  pip install -i https://pypi.anaconda.org/<username>/label/<branch>/simple <package>

If you use a requirements file, you can use the ``--extra-index-url`` parameter
to automatically search for packages in your `Anaconda.org`_ account::

  # requirements.txt
  --extra-index-url https://pypi.anaconda.org/<username>/label/<branch>/simple
  package1
  package2

Troubleshooting
---------------

Building may fail if the package requires compilation and depends on libraries
not installed on the system. For example, if the package depends on
``libffi`` you need to install the library and optionally set the proper
compilation flags, that is, edit ``build-setup.sh`` with the following
content::

  yum install -y libffi-devel

  export CFLAGS="${CFLAGS} $(pkg-config --cflags-only-I libffi)"

Additionaly you can debug the package building by starting the docker container
and interacting directly with the system::

  docker run -it --rm -v $PWD:/io -w /io quay.io/pypa/manylinux1_x86_64 bash

If you don't want to use manylinux wheels you can customize the build image in
the ``.travis.yml`` file and use ``scripts/build-wheels.sh`` rather than
``scripts/build-manylinux-wheels.sh``. You can also change the
``PYTHON_PREFIXES`` variable to target other python versions for manylinux wheels.

Caveats
-------

Not all packages can be converted into manylinux wheels. One example is
``cryptography`` which fails with an ``ImportError``. If you have this issue
you can either:

* Build non-manylinux wheels in your target docker image so you ensure wheel
  compatibility.
* Remove the package from your ``requirements.txt`` to avoid building it as
  wheel.
* Or remove the package from `Anaconda.org`_. This in case the package is a
  sub-dependency.

Acknowledgements
----------------

* `Continuum`_ is the company behind `Anaconda.org`_, `Conda`_ and other
  amazing python packages.
* `Manylinux`_ is the project with the goal to provide an convenient way to
  distribute binary packages as wheels.


.. _Anaconda.org: https://anaconda.org
.. _Conda: https://conda.io/docs/
.. _Travis CI: https://travis-ci.org/
.. _Continuum: https://continuum.io
.. _Manylinux: https://github.com/pypa/manylinux
