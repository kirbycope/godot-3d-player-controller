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
    
    # Extract repository name from URL
    local repo_name=$(basename "$repo_url" .git)
    local local_repo_path="C:/GitHub/$repo_name"
    
    # Check if repository exists locally first
    if [ -d "$local_repo_path" ]; then
        echo "Found local repository at: $local_repo_path"
        
        # Check if local repo is up to date with remote
        cd "$local_repo_path"
        
        # Fetch latest from remote to compare
        echo "Checking if local repository is up to date..."
        if git fetch origin "$branch" 2>/dev/null; then
            local local_commit=$(git rev-parse HEAD 2>/dev/null)
            local remote_commit=$(git rev-parse "origin/$branch" 2>/dev/null)
            
            if [ "$local_commit" = "$remote_commit" ]; then
                echo "Local repository is up to date with remote"
                echo "Using local copy instead of cloning..."
                
                # Check if the addon directory exists in the local repo
                local local_addon_path="$local_repo_path/addons/$addon_name"
                if [ -d "$local_addon_path" ]; then
                    # Define and clear the target directory
                    TARGET_DIR="$PROJECT_DIR/addons/$addon_name"
                    if [ -d "$TARGET_DIR" ]; then
                        echo "Removing existing $addon_name..."
                        rm -rf "$TARGET_DIR"
                    fi
                    mkdir -p "$TARGET_DIR"
                    
                    # Copy from local repository
                    cp -rf "$local_addon_path"/* "$TARGET_DIR/"
                    echo "✓ $addon_name installed successfully from local repository"
                    cd "$PROJECT_DIR"
                    return 0
                else
                    echo "Warning: Addon directory 'addons/$addon_name' not found in local repository"
                    echo "Falling back to cloning from origin..."
                fi
            else
                echo "Local repository is not up to date with remote"
                echo "Local commit: $local_commit"
                echo "Remote commit: $remote_commit"
                echo "Falling back to cloning from origin..."
            fi
        else
            echo "Unable to fetch from remote, falling back to cloning from origin..."
        fi
        
        cd "$PROJECT_DIR"
    else
        echo "Local repository not found at: $local_repo_path"
        echo "Cloning from origin..."
    fi
    
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
            cp -rf "addons/$addon_name"/* "$TARGET_DIR/"
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