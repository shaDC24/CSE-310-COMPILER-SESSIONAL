/*Problem 6: Custom Delimiter Parser

Task:
Write a lex program to parse a file with custom delimiters (e.g., data || value || end) and:

    Tokenize fields separated by ||.

    Detect missing delimiters (e.g., data || value end → Error).

Output:

    Print each token (e.g., TOKEN: data, DELIMITER: ||).

    Print errors for syntax violations.*/
%option noyywrap

%{
#include<stdio.h>
#include<iostream>
using namespace std;

string str="";
int line=1;
bool expw=false;
bool expd=false;
%}
WHITESPACE [ \t\r]*
DELIM "\|\|"
WORD [^ \t\n\|\|]+
VALID ({WORD}{WHITESPACE}{DELIM}{WHITESPACE})*{WORD}
MISSINGW ({WORD}*{WHITESPACE}{DELIM}{WHITESPACE})*{WORD}*
MISSINGD ({WORD}{WHITESPACE}{DELIM}*{WHITESPACE})*{WORD}

%%
\n {cout<<"The string is "<<str<<" at line no "<<line<<endl;
    line++;
    str="";}
{VALID} {
    cout<<"Line no : "<<line <<" VALID : "<<yytext<<endl;
    str+=yytext;

}
{MISSINGD} {
 
    cout<<"Line no : "<<line <<" DELIMITER is missing : "<<yytext<<endl;
    str+=yytext;
}
{MISSINGW} {
 
    cout<<"Line no : "<<line <<" WORD is missing : "<<yytext<<endl;
    str+=yytext;
}
{WHITESPACE} {
   // cout<<"Line no : "<<line <<" missing"<<endl;
    str+=yytext;
}
. {
    cout<<"Error at line "<<line<<endl;
}
<<EOF>> {
    return 0;
}
%%
int main()
{
    yylex();
    return 0;
}