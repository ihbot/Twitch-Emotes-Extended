#!/bin/bash

# This script will search the designated processing directory for new images
# to resize/format.

PROCESSING_DIRECTORY="./processing"
IMAGE_DIRECTORY="./emotes"
LUA_FILE="./main.lua"

for file in $PROCESSING_DIRECTORY
do
    # JPG/PNG file handling
    if [ "$file" == "*.png" || "$file" == "*.jpg"]
    then
        echo "Processing $file"
        # Resize, change extension to TGA and set in main image directory
        BASENAME=${file%.*}
        # Export basename to reuse as commit in GitHub Action
        export $BASENAME
        magick $file -resize 32x32 "$IMAGE_DIRECTORY/$BASENAME.tga"
        # Add entry in main.lua
        tac $LUA_FILE | awk '!p && /RegisterEmote/{print "RegisterEmote('$BASENAME', '$BASENAME.tga')"; p=1} 1' | tac
    else
        # Where we will add GIF options eventually
        echo "File extension is not JPG or PNG. Skipping."
done
