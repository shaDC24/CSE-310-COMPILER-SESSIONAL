/*Problem 2: Arithmetic Expression Lexer

Task:
Write a lex program to tokenize arithmetic expressions (e.g., 3 + 4 * (2 - 1)) and:

    Classify tokens into numbers, operators (+, -, *, /), and parentheses.

    Detect invalid tokens (e.g., 3 & 4 → Error: & is invalid).

    Ensure parentheses are balanced (e.g., 3 + (2 * 1 → Error).

Output:

    Print tokens line-by-line (e.g., NUMBER: 3, OPERATOR: +).

    Print errors if found.*/

%option noyywrap

%{
#include<iostream>
#include<string>
#include<stdio.h>
#include<stack>

using namespace std;

string str="";
stack<char>st;
int line=1;
bool isok=true;
%}

%%
\n {
  if(!st.empty())
  isok=false;  
  str+=yytext;
  if(isok)
  cout<<"Line no : "<<line<<" The corrected pattern is : "<<str<<endl;
  else
  {
    cout<<"Line no : "<<line<<" The invalid pattern is : "<<str<<endl;
  }
  line++;
  isok=true;
  str="";
  while(!st.empty())
  st.pop();

}
[ \t\r]+ {}
[0-9] {
  str+=yytext;  
}
['+'|'-'|'*'|'/'] {
str+=yytext;
}
['('] {
    str+=yytext;
    st.push(yytext[0]);
}
[')'] {
    str+=yytext;
    if(st.empty())
    isok=false;
    else if(st.top()=='(')
    st.pop();   
}
<<EOF>> {
if(!st.empty())
  isok=false;  
  if(isok)
  cout<<"Line no : "<<line<<" The corrected pattern is : "<<str<<endl;
  else
  {
    cout<<"Line no : "<<line<<" The invalid pattern is : "<<str<<endl;
  }   
  return 0; 
}
. {
    str+=yytext;
}

%%
int main()
{
    yylex();
    
    return 0;
}