#!/bin/bash

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

# Create the target directory if it doesn't exist
mkdir -p "../addons/3d_player_controller"

# Copy only the controller files to your addons directory
cp -r addons/3d_player_controller/* "../addons/3d_player_controller/"

# Clean up temporary directory
cd ..
rm -rf "$TEMP_DIR"
