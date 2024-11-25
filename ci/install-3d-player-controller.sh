#!/bin/bash

# 1. Open VS Code
# 2. Open New Terminal
# 3. Select 'git bash'
# 4. Run `bash ci/install-3d-player-controller.sh`


# Navigate to the addons folder in the current repository
rm addons -rf -f
mkdir -p addons
cd addons

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

# Move the directory to the correct location
mv addons/3d_player_controller ./  # Moves the directory up one level

# Remove the extra "addons" directory
rm -rf addons

# Remove any file in the current `addons` folder that is not a subdirectory
find . -maxdepth 1 -type f -exec rm -f {} +

# Remove the .git directory in addons (if present)
rm -rf .git

echo "Cloned the $SOURCE_DIR directory from $REPO_URL into addons"
