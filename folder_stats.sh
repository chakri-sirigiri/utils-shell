#!/bin/bash

# Check if an argument is provided
if [[ -z "$1" ]]; then
    echo "❌ Error: No folder path provided."
    echo "Usage: $0 /absolute/path/to/folder"
    exit 1
fi

# Assign the input argument to a variable
INPUT_PATH="$1"

# Validate if the path is an absolute directory
if [[ ! -d "$INPUT_PATH" ]]; then
    echo "❌ Error: Invalid directory path: $INPUT_PATH"
    exit 1
fi

echo "📂 Processing folder: $INPUT_PATH"
echo "----------------------------------------"

# Initialize counters for summary
TOTAL_FILES=0
TOTAL_FOLDERS=0
TOTAL_SIZE=0

# Loop through each subfolder inside the input path
for folder in "$INPUT_PATH"/*; do
    if [[ -d "$folder" ]]; then
        # Count files inside the folder (excluding directories)
        FILE_COUNT=$(find "$folder" -maxdepth 1 -type f | wc -l)
        
        # Count subfolders inside the folder
        FOLDER_COUNT=$(find "$folder" -maxdepth 1 -type d | wc -l)
        FOLDER_COUNT=$((FOLDER_COUNT - 1))  # Exclude the folder itself

        # Calculate total size of the folder
        SIZE=$(du -sb "$folder" | awk '{print $1}')  # Size in bytes

        # Print details for each subfolder
        echo "$(basename "$folder") $FILE_COUNT $FOLDER_COUNT $SIZE"

        # Update summary totals
        TOTAL_FILES=$((TOTAL_FILES + FILE_COUNT))
        TOTAL_FOLDERS=$((TOTAL_FOLDERS + FOLDER_COUNT))
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
    fi
done

# Include the input folder itself
MAIN_FILE_COUNT=$(find "$INPUT_PATH" -maxdepth 1 -type f | wc -l)
TOTAL_FILES=$((TOTAL_FILES + MAIN_FILE_COUNT))
TOTAL_FOLDERS=$((TOTAL_FOLDERS + 1))  # Count the main folder itself
MAIN_SIZE=$(du -sb "$INPUT_PATH" | awk '{print $1}')
TOTAL_SIZE=$((TOTAL_SIZE + MAIN_SIZE))

echo "----------------------------------------"
echo "Total $TOTAL_FILES $TOTAL_FOLDERS $TOTAL_SIZE"