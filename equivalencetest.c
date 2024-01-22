int bad()
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
    return 0;
}
