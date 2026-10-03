#!/bin/sh
# Copy sources into build/WoWDoom (assets are produced by build_assets.py)
set -e
mkdir -p build/WoWDoom/src
cp src/*.lua build/WoWDoom/src/
cp src/WoWDoom.toc build/WoWDoom/
cp wad/freedoom-0.13.0/COPYING.txt build/WoWDoom/FREEDOOM-COPYING.txt
echo "built build/WoWDoom"
