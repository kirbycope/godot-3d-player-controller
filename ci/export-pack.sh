#!/bin/bash

# Set variables
godot=$(grep -o '"godotTools.editorPath.godot4": *"[^"]*"' .vscode/settings.json | cut -d '"' -f 4)
preset="Web"
project=$(basename "$(pwd)")
path="$(pwd)\\ci\\${project}.pck"

# Print the command before running it
echo "\"$godot\" --headless --export-pack \"$preset\" \"$path\""

# Run Godot headless and export the project as a PCK file
"$godot" --headless --export-pack "$preset" "$path"
