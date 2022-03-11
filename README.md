# rust builder image for centos:7 with openssl, xmlsec1, libxml2 builder
I had to make an app work on centos7 and it took me a little longer than I care to admit to get it to build, and some other opens source projects, noteably
[rust-musl-builder](https://github.com/emk/rust-musl-builder) were a big help as I was not familiar with compiling C libraries from source.

### openssl
[![crates.io](https://img.shields.io/crates/v/openssl.svg)](https://crates.io/crates/openssl) 
### libxml2
[![crates.io](https://img.shields.io/crates/v/libxml.svg)](https://crates.io/crates/libxml)
### xmlsec1
[![crates.io](https://img.shields.io/crates/v/xmlsec.svg)](https://crates.io/crates/xmlsec) 


### Usage
```
docker run -v /home/project/src/:/home/rust/src joshuanitschke/rust-centos7-openssl-libxml2-xmlsec1-builder:tagname cargo build --release
```
