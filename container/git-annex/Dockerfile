FROM fedora:latest

# install basic packages
RUN dnf install -y git wget tar findutils

# create build directory
RUN mkdir /build
WORKDIR /build

# download and install haskell
RUN wget https://haskell.org/platform/download/7.10.3/haskell-platform-7.10.3-unknown-posix-x86_64.tar.gz && tar -xzf haskell-platform-7.10.3-unknown-posix-x86_64.tar.gz
RUN ./install-haskell-platform.sh

# install development requirements
RUN dnf install -y gcc make gmp-devel gnutls-devel libgsasl-devel libxml2-devel zlib-devel libidn-devel
RUN cabal update; cabal install c2hs

# download, compile and install git-annex
RUN git clone git://git-annex.branchable.com/ git-annex
WORKDIR /build/git-annex
RUN cabal install -j --only-dependencies
RUN cabal configure; cabal install --bindir=/usr/local/bin

# cleanup
WORKDIR /
RUN rm -rf /root/.cabal; rm -rf /tmp/*
RUN dnf remove -y gcc make gmp-devel gnutls-devel libgsasl-devel libxml2-devel zlib-devel libidn-devel; dnf autoremove -y

# Execute git-annex on exec
ENTRYPOINT ["/usr/local/bin/git-annex"]
