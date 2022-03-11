FROM centos:7

RUN yum update -y && yum install -y  \
    libstdc++-static \
    glibc-static \
    bash \
    autoconf \
    automake \
    make \
    libtool \
    wget \
    curl-devel \
    git \
    po4a \
    python \
    python-devel \
    centos-release-scl && \
    yum install -y llvm-toolset-7

WORKDIR /home/rust/src/

#RUN yum install -y centos-release-scl && \
#    yum install -y llvm-toolset-7 && \


# INSTALL RUST
RUN sh -c "curl https://sh.rustup.rs -sSf | sh -s -- -y"

# SETUP
RUN mkdir /home/rust/libs && mkdir /usr/local/compiled/

ENV XMLSEC_CRYPTO_OPENSSL=1
ARG OPENSSL_VERSION=1.1.1m
ARG LIBXSLT_VERSION=1.1.35
ARG LIBXML2_VERSION=2.9.12
ARG XMLSEC1_VERSION=1.2.32

# COMPILE OPENSSL
RUN ls /usr/include/linux && \
    mkdir -p /usr/local/compiled/include && \
    ln -s /usr/include/linux /usr/local/compiled/include/linux && \
    ln -s /usr/include/x86_64-linux-gnu/asm /usr/local/compiled/include/asm && \
    ln -s /usr/include/asm-generic /usr/local/compiled/include/asm-generic && \
    cd /tmp && \
    curl -fLO "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz" || \
        curl -fLO "https://www.openssl.org/source/old/1.1.1/openssl-$OPENSSL_VERSION.tar.gz" && \
    tar xvzf "openssl-$OPENSSL_VERSION.tar.gz" && cd "openssl-$OPENSSL_VERSION" && \
    env CC=gcc ./Configure no-shared no-zlib -fPIC --prefix=/usr/local/compiled -DOPENSSL_NO_SECURE_MEMORY linux-x86_64 && \
    env C_INCLUDE_PATH=/usr/local/compiled/include/ make depend && \
    env C_INCLUDE_PATH=/usr/local/compiled/include/ make && \
    make install && \
    rm /usr/local/compiled/include/linux /usr/local/compiled/include/asm /usr/local/compiled/include/asm-generic && \
    rm -r /tmp/*

# COMPILE LIBXML2
RUN cd /home/rust/libs && \
    curl -LO http://xmlsoft.org/sources/libxml2-$LIBXML2_VERSION.tar.gz && \
    tar xzf libxml2-$LIBXML2_VERSION.tar.gz && cd libxml2-$LIBXML2_VERSION && \
    ./configure --help && \
    CFLAGS='-fPIC' CC=gcc ./configure --enable-static --disable-shared --prefix=/usr/local/compiled && \
    make && make install && \
    cd ..

# COMPILE LIBXSLT
RUN cd /home/rust/libs && \
    curl -LO https://download.gnome.org/sources/libxslt/1.1/libxslt-$LIBXSLT_VERSION.tar.xz && \
    tar -xf libxslt-$LIBXSLT_VERSION.tar.xz && cd libxslt-$LIBXSLT_VERSION && \
    ./configure --help && \
    CFLAGS='-fPIC' CC=gcc ./configure --enable-static --disable-shared --with-libxml-src=../libxml2-2.9.12 --prefix=/usr/local/compiled && \
    make && make install && \
    cd ..


# COMPILE XMLSEC1
RUN cd /home/rust/libs && \
    curl -LO https://www.aleksey.com/xmlsec/download/xmlsec1-$XMLSEC1_VERSION.tar.gz && \
    tar xzf xmlsec1-$XMLSEC1_VERSION.tar.gz && cd xmlsec1-$XMLSEC1_VERSION && \
    ./configure --help && \
    CFLAGS='-std=c99 -lpthread -fPIC' CC=gcc ./configure --enable-static --enable-static-linking --disable-shared --with-openssl=/usr/local/compiled --with-libxslt=/usr/local/compiled  --with-libxml=/usr/local/compiled --with-default-crypto=openssl --disable-crypto-dl --with-threads=off --with-thread-alloc==off --prefix=/usr/local/compiled && \
    make && make install && \
    cd .. && rm -rf xmlsec1-$XMLSEC1_VERSION.tar.gz xmlsec1-$XMLSEC1_VERSION

# CLEANUP
RUN rm -rf /home/rust/libs

ENV LIBXML2=/usr/local/compiled/lib/libxml2.a \
    PKG_CONFIG_PATH=/usr/local/compiled/lib/pkgconfig \
    PATH="$PATH:/usr/local/compiled/bin"

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["bash", "/usr/bin/entrypoint.sh" ]
