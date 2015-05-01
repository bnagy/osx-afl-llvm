#!/usr/bin/env bash

LLVM_SRC_DIR=$PWD/llvm-3.5.0

if [ -f $LLVM_SRC_DIR/build/Release+Asserts/lib/afl.dylib  ]
then
	cp $LLVM_SRC_DIR/build/Release+Asserts/lib/afl.dylib ./afl-llvm-pass.so
	echo ""
	echo "Looks like the custom LLVM is already built!"
	echo "(Delete it manually if you want to rebuild)"
	exit 0
fi

if [ ! -f llvm-3.5.0.src.tar.xz ]
then
	echo ""
	echo "Downloading LLVM..." 1>&2
	wget "http://llvm.org/releases/3.5.0/llvm-3.5.0.src.tar.xz"
else
	echo ""
	echo "Found existing LLVM..."
fi

if [ ! -f cfe-3.5.0.src.tar.xz ]
then
	echo ""
	echo "Downloading Clang..." 1>&2
	wget "http://llvm.org/releases/3.5.0/cfe-3.5.0.src.tar.xz"
else
	echo ""
	echo "Found existing Clang..."
fi 

if [ ! -f compiler-rt-3.5.0.src.tar.xz ]
then
	echo ""
	echo "Downloading Compiler-RT..." 1>&2
	wget "http://llvm.org/releases/3.5.0/compiler-rt-3.5.0.src.tar.xz"
else
	echo ""
	echo "Found existing Compiler-RT..."
fi

echo ""
echo "Unpacking LLVM..." 1>&2
tar -xf llvm-3.5.0.src.tar.xz
mv llvm-3.5.0.src $LLVM_SRC_DIR

echo ""
echo "Unpacking Clang into tools..." 1>&2
tar -xf cfe-3.5.0.src.tar.xz
mv cfe-3.5.0.src $LLVM_SRC_DIR/tools/clang

echo ""
echo "Unpacking Compiler-RT into projects..." 1>&2
tar -xf compiler-rt-3.5.0.src.tar.xz
mv compiler-rt-3.5.0.src $LLVM_SRC_DIR/projects/compiler-rt

echo ""
echo "Copying afl-instr sources" 1>&2
echo "into LLVM source tree..." 1>&2
cp -r afl-instr $LLVM_SRC_DIR/projects/

echo ""
echo "Installing LLVM..." 1>&2
mkdir $LLVM_SRC_DIR/build
cd $LLVM_SRC_DIR/build
LLVM_BUILD_DIR=$PWD
export CC=gcc
export CXX=g++
../configure --enable-optimized 
REQUIRES_RTTI=1 make -j5
cd ../..
cp $LLVM_SRC_DIR/build/Release+Asserts/lib/afl.dylib ./afl-llvm-pass.so

echo "All done..."


