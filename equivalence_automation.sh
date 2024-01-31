#!/bin/bash


# Directories
CURRENT_DIR=$(pwd)
PROCESSED_DIR="$CURRENT_DIR/processed"
COMPILED_DIR="$CURRENT_DIR/compiled"
TEST_DIR="$CURRENT_DIR"  # Assuming test cases are in the current directory

# Ensure the processed and compiled directories exist
mkdir -p "$PROCESSED_DIR"
mkdir -p "$COMPILED_DIR"

# Loop through each CWE file in the current directory
for cwe_file in *CWE*.c; do
    # Extract the base name without the .c extension

    file_extension="${cwe_file##*.}"  # Extract the extension
    base_name=$(basename "$cwe_file" .$file_extension)  # Remove the extension from the filename
    echo "Processing $cwe_file..."

    # Call your Python script with the current file as an argument
    python extract_paraments.py "$cwe_file"

    # Assuming the python script generates a file named equivalencetest.c
    generated_file="equivalencetest.${file_extension}"

    # Compile the generated file
    gcc -o "$COMPILED_DIR/${base_name}_test" "$generated_file"

    # Check if compilation was successful
    if [ $? -eq 0 ]; then
        # Create a new S2E project
        s2e new_project "$COMPILED_DIR/${base_name}_test"
        cd $COMPILED_DIR


        # s2e run "$base_name"

        # Move the CWE file to the processed directory to indicate it has been handled
        mv "$cwe_file" "$PROCESSED_DIR/"

        echo "Completed processing of $cwe_file."
    else
        echo "Compilation failed for $cwe_file."
    fi
done

echo "Processing complete."
