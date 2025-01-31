#!/bin/bash

# Ensure IS_HOME is set
if [ -z "$IS_HOME" ]; then
    echo "Error: IS_HOME is not set. Please export IS_HOME to the correct Integration Server home directory."
    exit 1
fi

echo "IS_HOME is set to $IS_HOME"

# Get available packages
PACKAGES_DIR="packages"
PROPERTIES_DIR="properties"

if [ ! -d "$PACKAGES_DIR" ]; then
    echo "Error: $PACKAGES_DIR directory not found!"
    exit 1
fi

echo "Available packages to install:"
PACKAGES=($(ls -d "$PACKAGES_DIR"/*/ | xargs -n 1 basename))
echo "0) All Packages"
for i in "${!PACKAGES[@]}"; do
    echo "$((i+1))) ${PACKAGES[$i]}"
done

read -p "Enter the number(s) of packages to install (comma-separated, or 0 for all): " package_choice

# Create symlinks for packages
if [[ "$package_choice" == "0" ]]; then
    echo "Linking all packages..."
    for pkg in "${PACKAGES[@]}"; do
        ln -sfn "$(pwd)/$PACKAGES_DIR/$pkg" "$IS_HOME/packages/$pkg"
    done
else
    IFS=',' read -ra selected_packages <<< "$package_choice"
    for idx in "${selected_packages[@]}"; do
        pkg="${PACKAGES[$((idx-1))]}"
        ln -sfn "$(pwd)/$PACKAGES_DIR/$pkg" "$IS_HOME/packages/$pkg"
        echo "Linked $pkg"
    done
fi

# Identify property file locations
echo "Checking for instance-specific property files..."

INSTANCE_DIRS=($(find "$PROPERTIES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null))
USE_INSTANCE=false
SELECTED_PROPERTIES_DIR="$PROPERTIES_DIR"

if [ "${#INSTANCE_DIRS[@]}" -gt 0 ]; then
    echo "Instance-specific property files detected."
    echo "Available Instances:"
    echo "0) No specific instance (default properties folder)"
    for i in "${!INSTANCE_DIRS[@]}"; do
        echo "$((i+1))) ${INSTANCE_DIRS[$i]}"
    done
    read -p "Select an instance (enter number): " instance_choice

    if [[ "$instance_choice" -ne "0" ]]; then
        SELECTED_PROPERTIES_DIR="$PROPERTIES_DIR/${INSTANCE_DIRS[$((instance_choice-1))]}"
        USE_INSTANCE=true
    fi
fi

echo "Using properties from: $SELECTED_PROPERTIES_DIR"

# Get available environments from property file prefixes
ENVIRONMENTS=($(ls "$SELECTED_PROPERTIES_DIR" | grep -E '^[A-Z]{2}_.*\.(xml|txt)$' | cut -d'_' -f1 | sort -u))
if [ "${#ENVIRONMENTS[@]}" -eq 0 ]; then
    echo "No environment-specific property files found."
    exit 1
fi

# Force user to select one environment
echo "Available Environments (Select Only One):"
for i in "${!ENVIRONMENTS[@]}"; do
    echo "$((i+1))) ${ENVIRONMENTS[$i]}"
done

read -p "Select an environment (enter number): " env_choice

# Validate environment choice
if [[ "$env_choice" -lt 1 || "$env_choice" -gt "${#ENVIRONMENTS[@]}" ]]; then
    echo "Invalid selection. Please restart the script and choose a valid environment."
    exit 1
fi

SELECTED_ENV="${ENVIRONMENTS[$((env_choice-1))]}"
echo "Selected Environment: $SELECTED_ENV"

# List available property files for the selected environment
AVAILABLE_PROPERTY_FILES=()
for file in "$SELECTED_PROPERTIES_DIR"/*.{xml,txt}; do
    [[ -e "$file" ]] || continue  # Skip if no files exist
    filename=$(basename "$file")
    if [[ "$filename" == ${SELECTED_ENV}_* ]]; then
        AVAILABLE_PROPERTY_FILES+=("$filename")
    fi
done

if [ "${#AVAILABLE_PROPERTY_FILES[@]}" -eq 0 ]; then
    echo "No property files found for the selected environment."
    exit 1
fi

echo "Available property files:"
echo "0) All"
for i in "${!AVAILABLE_PROPERTY_FILES[@]}"; do
    echo "$((i+1))) ${AVAILABLE_PROPERTY_FILES[$i]}"
done

read -p "Select property files to link (comma-separated, or 0 for all): " file_choice

# Create symlinks for property files using ABSOLUTE paths
if [[ "$file_choice" == "0" ]]; then
    echo "Linking all property files for environment $SELECTED_ENV..."
    for file in "${AVAILABLE_PROPERTY_FILES[@]}"; do
        absolute_source="$(realpath "$SELECTED_PROPERTIES_DIR/$file")"
        clean_name=$(echo "$file" | cut -d'_' -f2-)  # Remove env prefix
        ln -sfn "$absolute_source" "$IS_HOME/properties/$clean_name"
        echo "Linked $absolute_source as $clean_name"
    done
else
    IFS=',' read -ra selected_files <<< "$file_choice"
    for idx in "${selected_files[@]}"; do
        file="${AVAILABLE_PROPERTY_FILES[$((idx-1))]}"
        absolute_source="$(realpath "$SELECTED_PROPERTIES_DIR/$file")"
        clean_name=$(echo "$file" | cut -d'_' -f2-)  # Remove env prefix
        ln -sfn "$absolute_source" "$IS_HOME/properties/$clean_name"
        echo "Linked $absolute_source as $clean_name"
    done
fi

echo "Symlink setup complete."