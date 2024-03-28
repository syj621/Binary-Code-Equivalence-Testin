#!/usr/bin/env python
# coding: utf-8

# In[240]:


import re


# In[241]:


def extract_functions(file_content):
    # 正则表达式模式以匹配C/C++函数声明
    function_pattern = r'(\w+)\s+(\w+)\s*\(([^)]*)\)\s*{'
    functions = re.findall(function_pattern, file_content)
    return functions


# In[242]:


def find_function_body(return_type, function_name, functions_lines):
    key = return_type + " " + function_name
    start_line = [index for index, item in enumerate(functions_lines, 0) if key in item][0]
    in_function_body = False
    brace_count = 0  # 用于跟踪花括号的嵌套层级
    for i, line in enumerate(functions_lines[start_line:]):
        if not in_function_body:
            if '{' in line:
                in_function_body = True
                brace_count = 1
        else:
            if '{' in line:
                brace_count = brace_count + 1
            if "}" in line:
                brace_count = brace_count - 1
            if brace_count == 0:
                if start_line + i < len(functions_lines):
                    return functions_lines[start_line:start_line + i + 1]
                else:
                    return functions_lines[start_line:-1]


# In[243]:


def find_called_functions(function_body):
    # 正则表达式模式以匹配函数调用
    call_pattern = r'\b(\w+)\s*\('
    called_functions = re.findall(call_pattern, function_body)
    return called_functions


# In[244]:


def extract_includes(file_content):
    include_pattern = r'^\s*#\s*include\s*["<][^">]+[">]'
    includes = re.findall(include_pattern, file_content, re.MULTILINE)
    return includes


# In[245]:


import sys

# Check to ensure a filename is provided
if len(sys.argv) < 2:
    print("Usage: 'extract paraments.py' <filename>")
    sys.exit(1)

filename = sys.argv[1]

with open(filename, 'r') as file:
    file_content = file.read()

cleaned_code = re.sub(r'/\*.*?\*/', '', file_content, flags=re.DOTALL)  # 使用正则表达式匹配和删除多行注释
cleaned_code = re.sub(r'//.*', '', cleaned_code)  # 使用正则表达式匹配和删除单行注释

functions_lines = [item for item in cleaned_code.split('\n') if item]
functions = extract_functions(file_content)
includes = extract_includes(file_content)
function_dic = {}
functions


# In[246]:


def find_duplicates(arr):
    seen = set()
    duplicates = set()

    for item in arr:
        if item in seen:
            duplicates.add(item)
        else:
            seen.add(item)

    return list(duplicates)


# In[247]:


functions_name_list = []

for k in functions:
    functions_name_list.append(k[1])
good_function = []


def starts_with_good(input_str):
    if input_str.startswith("good") and len(input_str) > 4:
        good_function.append(input_str)


for k in functions_name_list:
    starts_with_good(k)
good_function

# In[248]:


import random


def random_choice(my_array):
    if my_array:
        return random.choice(my_array)
    else:
        return None


selected_element = random_choice(good_function)


# In[249]:


def contains_bad(input_str):
    return "_bad" in input_str


bad_one = None
good_one = None
void = 0

# In[250]:


for return_type, function_name, function_para in functions:

    print("\n")
    print("rteurn value" + return_type)
    print("function name" + function_name)
    print("para" + function_para)
    function_body = find_function_body(return_type, function_name, functions_lines)
    print(function_body)

    if contains_bad(function_name) or function_name == 'bad':

        bad_body = function_body
        bad_name = function_name
        if return_type.lower() == 'void':
            void = 1
            continue;
    if selected_element.lower() == function_name.lower():
        good_body = function_body
        good_name = function_name
        if return_type.lower() == 'void':
            void = 1
            continue;

# In[251]:


bad_one

# In[252]:


good_one

# In[253]:


# accessing the return type
if void == 0:
    func_num = 0
first_function_return_type = functions[0][0]
# checking the file type that needs to be created
file_extension = 'cpp' if 'cpp' in file.name else 'c'
output_file_name = f"equivalencetest.{file_extension}"

with open(output_file_name, 'w') as output_file:
    pass

if void == 0:

    # writing the main
    with open(output_file_name, 'w') as output_file:
        headers = ["#include <inttypes.h>\n", "#include <s2e/s2e.h>\n"]
        for include in includes:
            output_file.write(include + '\n')
        output_file.write('\n')  # Add an extra newline for separation

        output_file.writelines(headers)
        for k in bad_body:
            output_file.write(k + "\n")
        for k in good_body:
            output_file.write(k + '\n')

        output_file.write("\n")
        output_file.write("\nint main()\n{\n")
        output_file.write("    " + str(first_function_return_type) + " x;\n")
        output_file.write("    s2e_make_symbolic(&x, sizeof(x), \"x\");\n")
        call_str_bad = f"    {return_type} func1 = {bad_name}(x);\n"
        output_file.write(call_str_bad)

        call_str_good = f"    {return_type} func2 = {good_name}(x);\n"
        output_file.write(call_str_good)

        output_file.write("    s2e_assert(func1 == func2);\n")

        '''
        #Camparing multiple functions

        func_calls = []

        for func_num, (return_type, function_name, function_para) in enumerate(functions):
            call_str = f"    {return_type} func{func_num} = {function_name}(x);\n"
            output_file.write(call_str)
            func_calls.append(f"func{func_num}")

        if len(func_calls) >= 2:
            # Create a comparison string that compares all function calls for equality
            comparison_string = " == ".join(func_calls)
            assert_statement = f"    s2e_assert({comparison_string});\n"
            output_file.write(assert_statement)
        '''

        output_file.write("    return 0;\n")
        output_file.write("}\n")
    print("success write")
else:
    print('the return type error')

# In[253]:




