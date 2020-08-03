#!/bin/bash
read -e -p "please choice how many file will you make(1 or 2) or yourself file.c and *.asm(3): " choice
if [ $choice == 1 ]; then
    read -e -p "please cin filename: " file
    if [ ! -f "$file".asm ]; then
	    echo "file not exit"
	    exit 0
    fi
    nasm -f elf32 "$file".asm
    gcc -m32 -o "$file" driver.c "$file".o asm_io.o
    ./"$file"
elif [ $choice == 2 ]; then
    read -e -p "please cin filename1: " file1
    read -e -p "please cin filename2: " file2
    if [ ! -f "$file1".asm ]; then
        echo "file1 not exit"
        exit 0
    fi
    if [ ! -f "$file2".asm ]; then
        echo "file2 not exit"
        exit 0
    fi
    nasm -f elf32 "$file1".asm
    nasm -f elf32 "$file2".asm
    gcc -m32 -o "$file1" driver.c "$file1".o "$file2".o asm_io.o
    ./"$file1"
elif [ $choice == 3 ]; then
    read -e -p "please cin filename1: " file1
    read -e -p "please cin filename2: " file2
    if [ ! -f "$file1".c ]; then
        echo "file1 not exit"
        exit 0
    fi
    if [ ! -f "$file2".asm ]; then
        echo "file2 not exit"
        exit 0
    fi
    nasm -f elf32 "$file2".asm
    gcc -m32 -o "$file2" "$file1".c "$file2".o asm_io.o
else
    echo "wrong choice"
fi
