#!/bin/bash

# Directories
CURRENT_DIR=$(pwd)
TEST_DIR="$CURRENT_DIR/test_cases"  # Test cases are in the 'test_cases' directory
PROCESSED_DIR="$CURRENT_DIR/processed"
COMPILED_DIR="$CURRENT_DIR/compiled"
PROJECT_DIR = "$CURRENT_DIR/projects/$base_name"

# Ensure the processed, compiled, and test case directories exist
mkdir -p "$PROCESSED_DIR"
mkdir -p "$COMPILED_DIR"
mkdir -p "$TEST_DIR"  # Make sure the test_cases directory exists

# Loop through each CWE file in the test_cases directory with .c or .cpp extension
for cwe_file in "$TEST_DIR"/*CWE*.{c,cpp}; do
    file_extension="${cwe_file##*.}"  # Extract the extension
    base_name=$(basename "$cwe_file" .$file_extension)  # Remove the extension from the filename
    echo "Processing $cwe_file..."

    # Call your Python script with the current file as an argument
    python extract paraments.py "$cwe_file"

    # Assuming the python script generates a file named equivalencetest.c or equivalencetest.cpp
    # Adjust the path according to where you expect the generated file to be
    #change/background: The folder with the test cases are in a child directory of the current directory.
    #The extract_paramaters.py is in the current directory alongside the equivalence_automation.sh.
    #I a not sure where the file gets generated.
    generated_file="${COMPILED_DIR}/equivalencetest.$file_extension"

    # Compile the generated file based on its extension
    if [ "$file_extension" == "c" ]; then
        gcc -I /home/victortangton/s2e_new/images/ubuntu-22.04-x86_64/guestfs/home/s2e/include -std=c99 -o "${COMPILED_DIR}/${base_name}" "$generated_file"
    elif [ "$file_extension" == "cpp" ]; then
        g++ -I /home/victortangton/s2e_new/images/ubuntu-22.04-x86_64/guestfs/home/s2e/include -std=c++11 -o "${COMPILED_DIR}/${base_name}" "$generated_file"
    fi

    # Check if compilation was successful
    if [ $? -eq 0 ]; then
        # Create a new S2E project
        s2e new_project "${COMPILED_DIR}/${base_name}"

        # Define the path to the s2e-config.lua file
        CONFIG_FILE="${CURRENT_DIR}/projects/${base_name}/s2e-config.lua"
        sed -i "/kleeArgs = {/a \ \ \ \ --Switch states only when the current one terminates\n    \"--use-dfs-search\"" "$CONFIG_FILE"
        sed -i "/plugins = {/a \ \ \ \ -- Enable S2E custom opcodes\n    \"BaseInstructions\",\n\n    -- Basic tracing required for test case generation\n    \"ExecutionTracer\",\n\n    -- Enable the test case generator plugin\n    \"TestCaseGenerator\"," "$CONFIG_FILE"

        # Change to the project directory
        cd "$PROJECT_DIR"

        # Run the s2e_run command in the project directory
        s2e_run

        # Move the CWE file to the processed directory to indicate it has been handled
        mv "$cwe_file" "$PROCESSED_DIR/"

        echo "Completed processing of $cwe_file."
    else
        echo "Compilation failed for $cwe_file."
    fi

    #To do: program going into the created project, and actualy running the s2e execution.
    #also program changing the config file to have dfs, bfs, etc. Get the debug file and csv
    #file and put it into one folder. Then, put that folder into a folder in the s2e directory called
    #results
done

echo "Processing complete."
