########################
# Ported from AWS setup script 6/3/2019
# Author: Nick Roberts (nroberts@alumni.cmu.edu)
FROM ubuntu:18.04
WORKDIR /autograder

# Some notes about this file:
#  - Docker images are built by running the RUN commands from top to bottom, and
#      images are cached after each RUN command. It's therefore desirable to
#      place more--frequently-modified commands at the bottom of the Dockerfile.
#  - The image created from this repo (cmu411:autograder) is referenced in
#      the other Dockerfiles: worker-docker-rust, worker-docker-sml, etc.
#      This Docker image, in addition to all these other Docker images, are
#      installed on the grading instances.
#  - There are three main places where packages are installed through apt-get:
#      (1) At the top of the Dockerfile (COMMON PACKAGE INSTALLATION).
#      (2) As part of the command that installs a compiler (e.g., we install
#            xz-utils before installing Haskell in the worker-docker-haskell
#            Dockerfile.)
#      (3) At the bottom of the Dockerfile.

#      Packages are installed at (1) if they are dependencies common to many
#      compiler installations, like curl, gcc, make, and python. Packages are
#      installed at (2) if they are needed only for one particular compiler's
#      installation (so that commenting out that compiler's installation command
#      will likewise remove the installation of that package). Finally, packages
#      are installed at (3) if they are packages that the user of the container
#      might like to use, like vim and emacs. If you wish to install a
#      "convenience program", you should add it to (3) as opposed to (1); adding
#      a dependency to (1) will invalidate the cache for all compiler
#      installations, and rebuilding the image will take much longer.
#  - Any time a RUN command involves `apt-get install`, it's appropriate to call
#      `apt-get update` earlier in the command so that, say, adding a dependency
#      will automatically choose the latest version of that package available in
#      the apt repository.
#  - Backslashes (\) allow single-line commands to be extended over multiple
#      lines. They are used for readability.

#------------------
# COMMON PACKAGE INSTALLATION
#------------------
# Install packages that many installations depend on.
RUN apt-get update && apt-get install -y \
  clang \
  curl \
  g++ \
  gcc \
  git \
  llvm \
  llvm-7 \
  make \
  python \
  sudo \
  ;

#----------------------
# C0 Installation
#----------------------
ENV c0_version=cc0-v0590-linux4.4.0-bin
RUN curl http://c0.typesafety.net/dist/$c0_version.tgz -O && \
  tar -xzf $c0_version.tgz && \
  sudo mv cc0 /opt/cc0 && \
  rm $c0_version.tgz && \
  echo "export PATH=/opt/cc0/bin:\$PATH" >> "$HOME/.bashrc"

#-----------------------
# SML/NJ Installation
#-----------------------

# SML/NJ
# After 64-bit support is added (supposedly sometime in 2019 or 2020), we
# will probably no longer need to install gcc-multilib and libc6-i386.
ENV smlnj_version=110.87
RUN apt-get update && apt-get install -y \
    gcc-multilib \
    libc6-i386 \
  && \
  cd /opt && \
  mkdir smlnj && \
  cd smlnj && \
  curl http://smlnj.cs.uchicago.edu/dist/working/$smlnj_version/config.tgz -LO && \
  tar xzf config.tgz && \
  rm config.tgz && \
  config/install.sh && \
  ln -s /opt/smlnj/bin/sml /usr/local/bin/ && \
  ln -s /opt/smlnj/bin/ml-* /usr/local/bin/
