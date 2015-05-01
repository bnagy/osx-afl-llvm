#!/usr/bin/env bash

set -e

LLVM_VERSION="3.5.0"
LLVM_SRC_DIR="${PWD}/llvm-${LLVM_VERSION}"

if [[ -f "${LLVM_SRC_DIR}/build/Release+Asserts/lib/afl.dylib" ]]; then
  cp "${LLVM_SRC_DIR}/build/Release+Asserts/lib/afl.dylib" afl-llvm-pass.so
  echo
  echo "Looks like the custom LLVM is already built!"
  echo "(Delete it manually if you want to rebuild)"
  exit 0
fi

if [[ ! -f "llvm-${LLVM_VERSION}.src.tar.xz" ]]; then
  echo
  echo "Downloading LLVM"
  curl -O "http://llvm.org/releases/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.xz"
else
  echo
  echo "Found existing LLVM"
fi

if [[ ! -f "cfe-${LLVM_VERSION}.src.tar.xz" ]]; then
  echo
  echo "Downloading Clang"
  curl -O "http://llvm.org/releases/${LLVM_VERSION}/cfe-${LLVM_VERSION}.src.tar.xz"
else
  echo
  echo "Found existing Clang"
fi 

if [[ ! -f "compiler-rt-${LLVM_VERSION}.src.tar.xz" ]]; then
  echo
  echo "Downloading Compiler-RT"
  curl -O "http://llvm.org/releases/${LLVM_VERSION}/compiler-rt-${LLVM_VERSION}.src.tar.xz"
else
  echo
  echo "Found existing Compiler-RT"
fi

echo
echo "Unpacking LLVM"
tar xf "llvm-${LLVM_VERSION}.src.tar.xz"
mv "llvm-${LLVM_VERSION}.src" "${LLVM_SRC_DIR}"

echo
echo "Unpacking Clang into tools"
tar xf "cfe-${LLVM_VERSION}.src.tar.xz"
mv "cfe-${LLVM_VERSION}.src" "${LLVM_SRC_DIR}/tools/clang"

echo
echo "Unpacking Compiler-RT into projects"
tar xf "compiler-rt-${LLVM_VERSION}.src.tar.xz"
mv "compiler-rt-${LLVM_VERSION}.src" "${LLVM_SRC_DIR}/projects/compiler-rt"

echo
echo "Copying afl-instr sources into LLVM source tree"
cp -r afl-instr "${LLVM_SRC_DIR}/projects/"

echo
echo "Installing LLVM"
mkdir "${LLVM_SRC_DIR}/build"
cd "${LLVM_SRC_DIR}/build"
export CC=gcc
export CXX=g++
../configure --enable-optimized 
REQUIRES_RTTI=1 make -j5
cd ../..
cp "${LLVM_SRC_DIR}/build/Release+Asserts/lib/afl.dylib" afl-llvm-pass.so

echo "All done"
