#!/bin/bash

# Enable extended globbing for pattern matching
shopt -s extglob

# Loop through all files that do NOT match *.sh, *.g4, or Ctester.cpp
for file in !(*.sh|*.g4|Ctester.cpp|Main.cpp|optfile.cpp); do
    # Only delete if it's a regular file
    if [[ -f "$file" ]]; then
        rm -f "$file"
    fi
done

# Remove the 'output' directory if it exists
rm -rf output
#python3 -m venv antlr4_venv
#source ./antlr4_venv/bin/activate
# pip install antlr4-tools
#git clone https://github.com/antlr/antlr4.git
#cd antlr4
#cd runtime/Cpp
#mkdir build && cd build
#cmake ..
#make
#sudo make install


#bash clean-script.sh

#bash r.sh input/input/loop.c