/*Problem 7: Python Indentation Checker

Task:
Write a lex program to validate Python-like indentation (spaces/tabs) and detect:

    Inconsistent indentation (e.g., mixing tabs and spaces).

    Dedent errors (e.g., jumping back multiple levels at once).

Output:

    Print "Valid" or "Error: Line 4: Inconsistent indentation".*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int current_indent = 0;
int line_number = 1;
int last_indent_char = 0; // 0=none, 1=space, 2=tab
int current_line_indent = 0;
int current_line_spaces = 0;
int current_line_tabs = 0;
%}

%option noyywrap

%%
^[ \t]+ {
    current_line_spaces = 0;
    current_line_tabs = 0;
    char *ptr = yytext;
    
    while (*ptr) {
        if (*ptr == ' ') {
            current_line_spaces++;
            last_indent_char = 1;
        } else if (*ptr == '\t') {
            current_line_tabs++;
            last_indent_char = 2;
        }
        ptr++;
    }
    
    current_line_indent = current_line_spaces + current_line_tabs * 4;
}

\n {
    // Check indentation for the current line
    int has_error = 0;
    char error_msg[100] = "";
    
    // Check for mixed spaces and tabs
    if (current_line_spaces > 0 && current_line_tabs > 0) {
        sprintf(error_msg, "Error: Line %d: Inconsistent indentation (mixed spaces and tabs)", line_number);
        has_error = 1;
    }
    // Check for indentation increase
    else if (current_line_indent > current_indent) {
        if (current_line_indent - current_indent > 4) {
            sprintf(error_msg, "Error: Line %d: Indentation increase too large", line_number);
            has_error = 1;
        } else {
            current_indent = current_line_indent;
        }
    }
    // Check for dedent
    else if (current_line_indent < current_indent) {
        if ((current_indent - current_line_indent) % 4 != 0) {
            sprintf(error_msg, "Error: Line %d: Dedent does not match outer level", line_number);
            has_error = 1;
        } else {
            current_indent = current_line_indent;
        }
    }
    
    if (has_error) {
        printf("Line %d: Invalid - %s\n", line_number, error_msg);
    } else {
        printf("Line %d: Valid\n", line_number);
    }
    
    line_number++;
    last_indent_char = 0;
    current_line_indent = 0;
    current_line_spaces = 0;
    current_line_tabs = 0;
}

. {
    /* Ignore other characters */
}

^[^ \t\n].* {
    // Line with no indentation
    int has_error = 0;
    
    if (current_indent > 0) {
        printf("Line %d: Invalid - Error: Unexpected dedent to level 0\n", line_number);
    } else {
        printf("Line %d: Valid\n", line_number);
    }
}

%%

int main() {
    yylex();
    return 0;
}