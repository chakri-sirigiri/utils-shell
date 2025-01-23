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
echo "Folder,Files,Subfolders,Size(Bytes)"

# Function to get folder size in bytes (Cross-platform)
get_size() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        du -sk "$1" | awk '{print $1 * 1024}'  # Convert KB to Bytes (macOS)
    else
        du -sb "$1" | awk '{print $1}'         # Get Bytes directly (Linux)
    fi
}

# Initialize counters for summary
TOTAL_FILES=0
TOTAL_FOLDERS=0
TOTAL_SIZE=0

# Loop through each subfolder inside the input path
for folder in "$INPUT_PATH"/*; do
    if [[ -d "$folder" ]]; then
        # Count files **recursively** (all levels)
        FILE_COUNT=$(find "$folder" -type f | wc -l)

        # Count subfolders **recursively**, excluding the folder itself
        FOLDER_COUNT=$(find "$folder" -type d | wc -l)
        FOLDER_COUNT=$((FOLDER_COUNT - 1))

        # Get folder size (in bytes)
        SIZE=$(get_size "$folder")

        # Update summary totals
        TOTAL_FILES=$((TOTAL_FILES + FILE_COUNT))
        TOTAL_FOLDERS=$((TOTAL_FOLDERS + FOLDER_COUNT))
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))

        # Print details for each subfolder **without commas in size**
        echo "$(basename "$folder"),$FILE_COUNT,$FOLDER_COUNT,$SIZE"
    fi
done

# Include the input folder itself
MAIN_FILE_COUNT=$(find "$INPUT_PATH" -type f | wc -l)
MAIN_FOLDER_COUNT=$(find "$INPUT_PATH" -type d | wc -l)
MAIN_FOLDER_COUNT=$((MAIN_FOLDER_COUNT - 1))
MAIN_SIZE=$(get_size "$INPUT_PATH")

TOTAL_FILES=$((TOTAL_FILES + MAIN_FILE_COUNT))
TOTAL_FOLDERS=$((TOTAL_FOLDERS + 1))  # Count the main folder itself
TOTAL_SIZE=$((TOTAL_SIZE + MAIN_SIZE))

echo "----------------------------------------"
echo "Total,$TOTAL_FILES,$TOTAL_FOLDERS,$TOTAL_SIZE"