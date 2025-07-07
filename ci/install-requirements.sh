#!/bin/bash

# Default requirements file
REQUIREMENTS_FILE="ci/requirements.txt"

# Check if custom requirements file is provided
if [ $# -gt 0 ]; then
    REQUIREMENTS_FILE="$1"
fi

# Check if requirements file exists
if [ ! -f "$REQUIREMENTS_FILE" ]; then
    echo "Error: Requirements file '$REQUIREMENTS_FILE' not found!"
    echo "Usage: $0 [requirements_file]"
    exit 1
fi

echo "Installing Godot addons from $REQUIREMENTS_FILE..."
echo "=================================================="

# Get the absolute path of the project directory
PROJECT_DIR=$(pwd -W)

# Function to install a single addon
install_addon() {
    local repo_url=$1
    local addon_name=$2
    local branch=${3:-main}
    
    echo ""
    echo "Installing: $addon_name"
    echo "Repository: $repo_url"
    echo "Branch: $branch"
    echo "----------------------------------------"
    
    # Create a temporary directory for cloning
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Initialize a new git repository
    git init
    
    # Add the remote repository
    git remote add origin "$repo_url"
    
    # Fetch the remote repository
    git fetch
    
    # Enable sparse checkout
    git sparse-checkout init --cone
    
    # Set the directory to checkout
    git sparse-checkout set "addons/$addon_name"
    
    # Check if the specified branch exists, fallback to master if main doesn't exist
    if ! git ls-remote --heads origin "$branch" | grep -q "$branch"; then
        echo "Branch '$branch' not found, checking for common alternatives..."
        if git ls-remote --heads origin "master" | grep -q "master"; then
            branch="master"
            echo "Using 'master' branch instead"
        elif git ls-remote --heads origin "main" | grep -q "main"; then
            branch="main"
            echo "Using 'main' branch instead"
        else
            echo "✗ Neither 'main' nor 'master' branch found"
            cd "$PROJECT_DIR"
            rm -rf "$TEMP_DIR"
            return 1
        fi
    fi
    
    # Pull the selected directory from the specified branch
    if git pull origin "$branch"; then
        # Define and clear the target directory
        TARGET_DIR="$PROJECT_DIR/addons/$addon_name"
        if [ -d "$TARGET_DIR" ]; then
            echo "Removing existing $addon_name..."
            rm -rf "$TARGET_DIR"
        fi
        mkdir -p "$TARGET_DIR"
        
        # Check if the addon directory exists in the cloned repo
        if [ -d "addons/$addon_name" ]; then
            # Force copy with verbose output
            cp -rfv "addons/$addon_name"/* "$TARGET_DIR/"
            echo "✓ $addon_name installed successfully"
        else
            echo "✗ Addon directory 'addons/$addon_name' not found in repository"
            cd "$PROJECT_DIR"
            rm -rf "$TEMP_DIR"
            return 1
        fi
    else
        echo "✗ Failed to pull from repository"
        cd "$PROJECT_DIR"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Clean up temporary directory
    cd "$PROJECT_DIR"
    rm -rf "$TEMP_DIR"
    return 0
}

# Read requirements file and install addons
failed_installs=()
total_addons=0

while IFS= read -r line; do
    # Skip empty lines and comments
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    # Parse the line and strip any whitespace/special characters
    line=$(echo "$line" | tr -d '\r\n' | sed 's/[[:space:]]*$//')
    read -r addon_name repo_url branch <<< "$line"
    
    # Trim whitespace from each field
    addon_name=$(echo "$addon_name" | xargs)
    repo_url=$(echo "$repo_url" | xargs)
    branch=$(echo "$branch" | xargs)
    
    # Debug output
    echo "Parsed: addon='$addon_name' repo='$repo_url' branch='$branch'"
    
    # Skip if essential fields are missing
    if [[ -z "$addon_name" || -z "$repo_url" ]]; then
        echo "Warning: Skipping malformed line: $line"
        continue
    fi
    
    # Set default branch if not specified
    if [[ -z "$branch" ]]; then
        branch="main"
    fi
    
    echo "Using branch: '$branch'"
    
    total_addons=$((total_addons + 1))
    
    if ! install_addon "$repo_url" "$addon_name" "$branch"; then
        failed_installs+=("$addon_name")
    fi
    
done < "$REQUIREMENTS_FILE"

echo ""
echo "=================================================="
echo "Installation Summary:"
echo "Total addons processed: $total_addons"

if [ ${#failed_installs[@]} -eq 0 ]; then
    echo "✓ All addons installed successfully!"
else
    echo "✗ Failed installations (${#failed_installs[@]}):"
    for addon in "${failed_installs[@]}"; do
        echo "  - $addon"
    done
    exit 1
fi

echo ""
echo "All Godot addons have been installed from $REQUIREMENTS_FILE"