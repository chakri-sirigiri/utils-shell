#!/bin/bash

# Define files and folders to ignore (space-separated)
IGNORE_FILES=".DS_Store anotherfile.txt temp.log"
IGNORE_FOLDERS=".@__thumb .dtrash backup"

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
echo "Folder,Files,Subfolders,Total Items,Size(Bytes),Human Readable Size"

# Function to get folder size in bytes (Cross-platform)
get_size() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        du -sk "$1" | awk '{print $1 * 1024}'  # Convert KB to Bytes (macOS)
    else
        du -sb "$1" | awk '{print $1}'         # Get Bytes directly (Linux/QNAP)
    fi
}

# Function to convert size in bytes to human-readable format
human_readable_size() {
    local size=$1
    local units=("B" "KB" "MB" "GB" "TB" "PB")
    local i=0
    while ((size >= 1024)) && ((i < ${#units[@]} - 1)); do
        size=$((size / 1024))
        i=$((i + 1))
    done
    echo "$size ${units[$i]}"
}

# Function to count valid files and folders manually (BusyBox-compatible)
count_files() {
    local dir="$1"
    local count=0
    while IFS= read -r file; do
        skip=false
        for ignore in $IGNORE_FILES; do
            [[ "$file" == *"$ignore" ]] && skip=true && break
        done
        for ignore in $IGNORE_FOLDERS; do
            [[ "$file" == *"$ignore"* ]] && skip=true && break
        done
        $skip || ((count++))
    done < <(find "$dir" -type f)
    echo "$count"
}

count_folders() {
    local dir="$1"
    local count=0
    while IFS= read -r folder; do
        skip=false
        for ignore in $IGNORE_FOLDERS; do
            [[ "$folder" == *"$ignore"* ]] && skip=true && break
        done
        $skip || ((count++))
    done < <(find "$dir" -type d)
    echo "$((count - 1))"  # Exclude the base folder itself
}

# Initialize summary totals
TOTAL_FILES=0
TOTAL_FOLDERS=0
TOTAL_ITEMS=0
TOTAL_SIZE=0

# Loop through each subfolder inside the input path
for folder in "$INPUT_PATH"/*; do
    if [[ -d "$folder" ]]; then
        # Check if this folder is in the IGNORE_FOLDERS list
        for f in $IGNORE_FOLDERS; do
            [[ "$(basename "$folder")" == "$f" ]] && continue 2
        done

        # Count files and folders manually
        FILE_COUNT=$(count_files "$folder")
        FOLDER_COUNT=$(count_folders "$folder")

        # Calculate total items (files + folders)
        TOTAL_ITEM_COUNT=$((FILE_COUNT + FOLDER_COUNT))

        # Get folder size
        SIZE=$(get_size "$folder")

        # Convert to human-readable size
        HUMAN_READABLE_SIZE=$(human_readable_size "$SIZE")

        # Update summary totals
        TOTAL_FILES=$((TOTAL_FILES + FILE_COUNT))
        TOTAL_FOLDERS=$((TOTAL_FOLDERS + FOLDER_COUNT))
        TOTAL_ITEMS=$((TOTAL_ITEMS + TOTAL_ITEM_COUNT))
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))

        # Print details for each subfolder
        echo "$(basename "$folder"),$FILE_COUNT,$FOLDER_COUNT,$TOTAL_ITEM_COUNT,$SIZE,$HUMAN_READABLE_SIZE"
    fi
done

# Count **only** additional files in the main directory (excluding ignored files)
MAIN_FILE_COUNT=0
while IFS= read -r file; do
    skip=false
    for ignore in $IGNORE_FILES; do
        [[ "$file" == *"$ignore" ]] && skip=true && break
    done
    $skip || ((MAIN_FILE_COUNT++))
done < <(find "$INPUT_PATH" -maxdepth 1 -type f)

# Count **only** direct subfolders in the main directory (excluding ignored folders)
MAIN_FOLDER_COUNT=0
while IFS= read -r folder; do
    skip=false
    for ignore in $IGNORE_FOLDERS; do
        [[ "$folder" == *"$ignore"* ]] && skip=true && break
    done
    $skip || ((MAIN_FOLDER_COUNT++))
done < <(find "$INPUT_PATH" -maxdepth 1 -type d)

# Total items in main folder
MAIN_TOTAL_ITEMS=$((MAIN_FILE_COUNT + MAIN_FOLDER_COUNT))

# Get main folder size
MAIN_SIZE=$(get_size "$INPUT_PATH")

# Convert to human-readable size
MAIN_HUMAN_READABLE_SIZE=$(human_readable_size "$MAIN_SIZE")

# Final summary (reuse accumulated totals and just add main folder values)
GRAND_TOTAL_FILES=$((TOTAL_FILES + MAIN_FILE_COUNT))
GRAND_TOTAL_FOLDERS=$((TOTAL_FOLDERS + 1))  # Count the main folder itself
GRAND_TOTAL_ITEMS=$((TOTAL_ITEMS + MAIN_TOTAL_ITEMS))
GRAND_TOTAL_SIZE=$((TOTAL_SIZE + MAIN_SIZE))

# Print final summary with human-readable size
echo "----------------------------------------"
echo "Total,$GRAND_TOTAL_FILES,$GRAND_TOTAL_FOLDERS,$GRAND_TOTAL_ITEMS,$GRAND_TOTAL_SIZE,$MAIN_HUMAN_READABLE_SIZE"