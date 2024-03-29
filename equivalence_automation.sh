#!/bin/bash

# Directories
CURRENT_DIR=$(pwd)
TEST_DIR="$CURRENT_DIR/test_cases"  # Test cases are in the 'test_cases' directory
PROCESSED_DIR="$CURRENT_DIR/processed"
COMPILED_DIR="$CURRENT_DIR/compiled"

# Ensure the processed, compiled, and test case directories exist and have appropriate permissions
mkdir -p "$PROCESSED_DIR"
mkdir -p "$COMPILED_DIR"
mkdir -p "$TEST_DIR"  # Make sure the test_cases directory exists
chmod -R 777 "$PROCESSED_DIR"
chmod -R 777 "$COMPILED_DIR"
chmod -R 777 "$TEST_DIR"

# Loop through each CWE file in the test_cases directory with .c or .cpp extension
for cwe_file in "$TEST_DIR"/*CWE*.{c,cpp}; do
    file_extension="${cwe_file##*.}"  # Extract the extension
    base_name=$(basename "$cwe_file" .$file_extension)  # Remove the extension from the filename
    echo "Processing $cwe_file..."

    # Call your Python script with the current file as an argument
    sudo python3 extract_paraments.py "$cwe_file"

    # Assuming the python script generates a file named equivalencetest.c or equivalencetest.cpp
    generated_file="${COMPILED_DIR}/equivalencetest.$file_extension"

    # Compile the generated file based on its extension
    if [ "$file_extension" == "c" ]; then
        gcc -I /home/victortangton/s2e_new/images/ubuntu-22.04-x86_64/guestfs/home/s2e/include -std=c99 -o "${base_name}" "$generated_file"
    elif [ "$file_extension" == "cpp" ]; then
        g++ -I /home/victortangton/s2e_new/images/ubuntu-22.04-x86_64/guestfs/home/s2e/include -std=c++11 -o "${base_name}" "$generated_file"
    fi
    mv $base_name COMPILED_DIR
    
    # Check if compilation was successful
    if [ $? -eq 0 ]; then
        PROJECT_DIR="$CURRENT_DIR/projects/$base_name"
        mkdir -p "$PROJECT_DIR"
        chmod -R 777 "$PROJECT_DIR"

        # Create a new S2E project
        s2e new_project "${COMPILED_DIR}/${base_name}"

        # Define the path to the s2e-config.lua file
        CONFIG_FILE="$PROJECT_DIR/s2e-config.lua"
        sudo sed -i "/kleeArgs = {/a \ \ \ \ --Switch states only when the current one terminates\n    \"--use-dfs-search\"" "$CONFIG_FILE"
        sudo sed -i "/plugins = {/a \ \ \ \ -- Enable S2E custom opcodes\n    \"BaseInstructions\",\n\n    -- Basic tracing required for test case generation\n    \"ExecutionTracer\",\n\n    -- Enable the test case generator plugin\n    \"TestCaseGenerator\"," "$CONFIG_FILE"

        # Change to the project directory and run s2e
        cd "$PROJECT_DIR"
        s2e_run

        # Move the CWE file to the processed directory to indicate it has been handled
        mv "$cwe_file" "$PROCESSED_DIR/"

        echo "Completed processing of $cwe_file."
    else
        echo "Compilation failed for $cwe_file."
    fi
done

echo "Processing complete."
