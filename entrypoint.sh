#!/bin/bash
source /root/.bashrc
source scl_source enable llvm-toolset-7
exec "$@"