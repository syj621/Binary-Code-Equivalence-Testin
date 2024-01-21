int CWE789_Uncontrolled_Mem_Alloc__malloc_char_fscanf_01_bad()
{
    size_t data;
    
    data = 0;
    
    fscanf(stdin, "%zu", &data);
    {
        char * myString;
        
        
        if (data > strlen(HELLO_STRING))
        {
            myString = (char *)malloc(data*sizeof(char));
            if (myString == NULL) {exit(-1);}
            
            strcpy(myString, HELLO_STRING);
            printLine(myString);
            free(myString);
        }
        else
        {
            printLine("Input is less than the length of the source string");
        }
    }
}
static int goodG2B()
{
    size_t data;
    
    data = 0;
    
    data = 20;
    {
        char * myString;
        
        
        if (data > strlen(HELLO_STRING))
        {
            myString = (char *)malloc(data*sizeof(char));
            if (myString == NULL) {exit(-1);}
            
            strcpy(myString, HELLO_STRING);
            printLine(myString);
            free(myString);
        }
        else
        {
            printLine("Input is less than the length of the source string");
        }
    }
}


int main()
{
    int x;
    s2e_make_symbolic(&x, sizeof(x), "x");
    int func0 = CWE789_Uncontrolled_Mem_Alloc__malloc_char_fscanf_01_bad(x);
    int func1 = goodG2B(x);
    int func2 = goodB2G(x);
    void func3 = CWE789_Uncontrolled_Mem_Alloc__malloc_char_fscanf_01_good(x);
    int func4 = main(x);
    s2e_assert(func0 == func1 == func2 == func3 == func4);
    return 0;
}
