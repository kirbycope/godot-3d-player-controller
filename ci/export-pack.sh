#!/bin/bash

# Set variables
godot="C:\\Users\\kirby\\OneDrive\\Desktop\\Godot Game Engine.exe"
preset="Web"
project=$(basename "$(pwd)")
path="C:\\GitHub\\${project}\ci\\${project}.pck"

# Print the command before running it
echo "\"$godot\" --headless --export-pack \"$preset\" \"$path\""

# Run Godot headless and export the project as a PCK file
"$godot" --headless --export-pack "$preset" "$path"
