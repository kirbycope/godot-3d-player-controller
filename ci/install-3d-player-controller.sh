#!/bin/bash

# Get the absolute path of the project directory
PROJECT_DIR=$(pwd -W)

# Create a temporary directory for cloning
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Define the repository URL and directory to clone
REPO_URL="https://github.com/kirbycope/godot-3d-player-controller.git"
DIRECTORY="addons/3d_player_controller"
BRANCH="main"

# Initialize a new git repository
git init

# Add the remote repository
git remote add origin "$REPO_URL"

# Fetch the remote repository
git fetch

# Enable sparse checkout
git sparse-checkout init --cone

# Set the directory to checkout
git sparse-checkout set "$DIRECTORY"

# Pull the selected directory from the specified branch
git pull origin "$BRANCH"

# Define and clear the target directory
TARGET_DIR="$PROJECT_DIR/addons/3d_player_controller"
if [ -d "$TARGET_DIR" ]; then
    rm -rf "$TARGET_DIR"
fi
mkdir -p "$TARGET_DIR"

# Force copy with verbose output
cp -rfv addons/3d_player_controller/* "$TARGET_DIR/"

# Clean up temporary directory
cd "$PROJECT_DIR"
rm -rf "$TEMP_DIR"
