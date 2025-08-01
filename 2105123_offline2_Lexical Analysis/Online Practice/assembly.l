/*
Problem 9: Assembly Label Detector

Task:
Write a lex program to parse assembly code and:

    Detect labels (e.g., loop:).

    Check for duplicate labels (e.g., loop: defined twice → Error).

Output:

    Print labels and their line numbers.

    Flag duplicates.
*/
%option noyywrap
%{

#include<iostream>
#include<string>
#include <vector>
using namespace std;
int line=1;
vector<string>label;
bool isdup(string &name)
{
for(int i=0;i<label.size();i++)
{
    if(label[i]==name)
    return true;
}
return false;
}
%}
WHITESPACE [ \t\r]*
DIGIT [0-9]
ALPHA [a-zA-Z_]
ID {ALPHA}({ALPHA}|{DIGIT})*

%%
\n {line++;}
{WHITESPACE}{ID}{WHITESPACE}":" {
    string name(yytext,strlen(yytext)-1);
   if(isdup(name))
   cout<<line<<" no ... contains "<<name<<" duplicate value"<<endl;
   else {
    cout<<line<<" no ... contains "<<name<<" value"<<endl;
    label.push_back(name);
   }
}
. {
    ;
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

