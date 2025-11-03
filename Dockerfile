# Some notes about this file:
#  - Docker images are built by running the RUN commands from top to bottom, and
#      images are cached after each RUN command. It's therefore desirable to
#      place more--frequently-modified commands at the bottom of the Dockerfile.
#  - The image created from this repo (cmu411:autograder) is referenced in
#      the other Dockerfiles: worker-docker-rust, worker-docker-sml, etc.
#      This Docker image, in addition to all these other Docker images, are
#      installed on the grading instances.
#  - Any time a RUN command involves `apt-get install`, it's appropriate to call
#      `apt-get update` earlier in the command so that, say, adding a dependency
#      will automatically choose the latest version of that package available in
#      the apt repository.
#  - Backslashes (\) allow single-line commands to be extended over multiple
#      lines. They are used for readability.


FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /autograder

#------------------------------
# Common Package Installation
#------------------------------
RUN apt-get update && apt-get install -y \
   curl \
   g++ \
   gcc \
   git \
   make \
   python3 \
   rlwrap \
   sudo \
   wget \
   gnupg \
   software-properties-common lsb-release \
&& rm -rf /var/lib/apt/lists/*


#------------------------------
# Install LLVM version 21 
#
# LLVM version 21 isn't available by default in Ubuntu 22.04's apt repos
#------------------------------
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh \
&& ./llvm.sh 21 && rm llvm.sh \
&& apt-get update && apt-get install -y \
    clang-21 \
    lldb-21 \
    lld-21 \
    llvm-21 \
    llvm-21-dev \
&& update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-21 100 \
&& update-alternatives --install /usr/bin/llc llc /usr/bin/llc-21 100 \
&& update-alternatives --install /usr/bin/opt opt /usr/bin/opt-21 100 \
&& update-alternatives --install /usr/bin/clang clang /usr/bin/clang-21 100 \
&& update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-21 100 \
&& update-alternatives --install /usr/bin/lld lld /usr/bin/lld-21 100 \
&& update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-21 100


#------------------------------
# C0 Installation
#------------------------------
RUN wget https://cs.cmu.edu/~15411/downloads/cc0-debian.deb \
 && apt-get update && apt-get install -y ./cc0-debian.deb \
 && rm cc0-debian.deb \
 && rm -rf /var/lib/apt/lists/*


#------------------------------
# SML/NJ Installation
#------------------------------
ENV smlnj_version=110.99
RUN cd /opt \
 && mkdir smlnj \
 && cd smlnj \
 && wget http://smlnj.cs.uchicago.edu/dist/working/$smlnj_version/config.tgz \
 && tar xzf config.tgz \
 && rm config.tgz \
 && config/install.sh \
 && ln -s /opt/smlnj/bin/sml /usr/local/bin/ \
 && ln -s /opt/smlnj/bin/ml-* /usr/local/bin/


#-----------------------
# MLton Installation
#-----------------------
ENV mlton_version=20210117
ENV mlton_pkg=mlton-$mlton_version-1.amd64-linux
RUN apt-get update && apt-get install -y \
    libgmp-dev \
  && \
  cd /opt && \
  mkdir mlton && \
  cd mlton && \
  curl https://sourceforge.net/projects/mlton/files/mlton/$mlton_version/$mlton_pkg.tgz -LO && \
  tar xvf $mlton_pkg.tgz && \
  rm $mlton_pkg.tgz && \
  make -C $mlton_pkg


#-----------------------
# Molasses Installation
#
# At some point, smlnj changed the type for Compiler.version. Molasses was patched to
# account for this change, but we're still using an older version of smlnj, so we now need
# to use an older version of Molasses
# - smlnj update: https://github.com/T-Brick/molasses/issues/2
# - version we're using:
#     https://github.com/T-Brick/molasses/commit/d86c70923cabb39d34d2cc198d80bac248d564f8
#-----------------------
RUN cd /opt && \
  git clone --recurse-submodules -j8 https://github.com/T-Brick/molasses && \
  cd molasses && \
  git reset --hard d86c709 && \
  make && \
  make repl

RUN echo 'alias molasses=/opt/molasses/molasses' >> "$HOME/.bashrc"
RUN echo 'alias smlnj="rlwrap sml @SMLload=/opt/molasses/molasses-repl"' >> "$HOME/.bashrc"


#--------------
# Misc Package Installation
# Add convenience packages for students using container
#--------------
RUN apt-get update && apt-get install -y \
    bison \
    emacs \
    flex \
    gdb \
    python3 \
    vim \
&& rm -rf /var/lib/apt/lists/*
