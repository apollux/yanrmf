
#include "Dir_1/Dir_1b/include/dir_1b_file1.h"
#include "Dir_1/Dir_1b/include/dir_1b_file2.h"
#include "Dir_1/Dir_1a/dir_1a_file2.h"
#include "Dir_1/Dir_1a/dir_1a_file1.h"
#include "Dir_1/dir_1_file2.h"
#include "top_a.h"

int main()
{
    function_top_a();
    function_dir_1_file2();
    function_dir_1a_file1();
    function_dir_1a_file2(); 
    function_dir_1b_file1();
    function_dir_1b_file2(); 
    return 0;
}

