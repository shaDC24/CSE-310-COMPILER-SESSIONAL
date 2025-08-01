/*
Problem 10: SQL WHERE Clause Parser

Task:
Write a lex program to tokenize SQL WHERE clauses (e.g., WHERE age > 25 AND name = 'Alice') and:

    Classify tokens (keywords, operators, literals).

    Detect unclosed strings (e.g., name = 'Alice → Error).

Output:

    Print token types (e.g., KEYWORD: WHERE, OPERATOR: >).

    Print syntax errors.
*/
%option noyywrap

%{
    #include <iostream>
    #include <stdio.h>
    #include <stack>

    using namespace std;
    int line=1;
    stack<char>st;

%}
ALPHA [a-zA-Z_]
DIGIT [0-9]
NUMBER {DIGIT}+(\.{DIGIT}+)*
ID {ALPHA}+({ALPHA}|{DIGIT})*

%%
\n {cout<<"Newline started..."<<endl;
    if(!st.empty())
    {
     cout<<"At line no : "<<line <<" Not matching parenthesis found  extra ("<<endl;
    }
    while(!st.empty()) st.pop();
    line++;}
"WHERE" {
    cout<<"At line no : "<<line <<" Keyword : "<<yytext<<endl;
}
{ID} {
   cout<<"At line no : "<<line <<" Identifier : "<<yytext<<endl; 
}
"+"|"-"|"*"|"\\"|"<="|">="|"<"|">"|"=" {
   cout<<"At line no : "<<line <<" operator : "<<yytext<<endl;  
}
{NUMBER} {
    cout<<"At line no : "<<line <<" NUMBER : "<<yytext <<endl; 
}
\"[^\"]*\" {
    cout<<"At line no : "<<line <<" STRING : "<<yytext <<endl; }
\'[^\']*\' {
    cout<<"At line no : "<<line <<" STRING : "<<yytext <<endl; }     
\"[^\"\n]* {
    cout<<"At line no : "<<line <<" Unfinished literal of STRING : "<<yytext<<endl; }
\'[^\'\n]* {
    cout<<"At line no : "<<line <<" Unfinished literal of STRING : "<<yytext<<endl; }  
"(" {
    st.push('(');
    cout<<"At line no : "<<line <<" LPAREN : "<<yytext<<endl;
}    
")" {
    if(st.empty())
    cout<<"At line no : "<<line<<" does not have matching parentheeeeesis "<<yytext<<endl;
    else if(st.top()=='(')
    {st.pop();
    cout<<"At line no : "<<line <<" RPAREN : "<<yytext<<endl;
    }
}

. {}
<<EOF>> {return 0;}
%%
int main() {
    yylex();
    return 0;
}