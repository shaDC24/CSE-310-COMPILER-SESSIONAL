/*
Problem 8: Email and URL Extractor

Task:
Write a lex program to scan a text file and:

    Extract all email addresses (e.g., user@domain.com).

    Extract all URLs (e.g., https://example.com).

    Reject invalid formats (e.g., user@.com → Error).

Output:

    Print emails and URLs line-by-line.

    Mark invalid patterns.
*/
%option noyywrap

%{
 #include<iostream>
 #include<stdio.h>
 #include<string>
using namespace std;
 int line=1;
string str="";   
%}
WHITESPACE [ \t\r]+
ALPHA [a-zA-Z_]
DIGIT [0-9]
ID {ALPHA}({ALPHA}|{DIGIT})*
GMAIL ({ID}(\.{ID})*)@{ID}\.{ALPHA}+
LINK {ALPHA}+:\/\/{ID}(\.{ALPHA}+)*(\/{ID})*([?]?{ALPHA}+={DIGIT}+)*
INVALID_EMAIL0 {ID}@{ID}*  
INVALID_EMAIL1  {ID}@\.{ID}*    
INVALID_EMAIL2  @{ID}(\.{ID})*         
INVALID_EMAIL3  {ID}@{ID}\.[^a-zA-Z]  
INVALID_EMAIL4  {ID}\.{2,}@{ID}       
INVALID_EMAIL5  {ID}@{ID}\.[a-zA-Z]   
INVALID_URL0    {ALPHA}+[:]?\/\?(\/)+{ID}(-{ID})*(\.{ALPHA}+)*(\/{ID})*([?]?{ALPHA}+={DIGIT}+)*


%%
\n {
    str+=yytext;
    //if(!str.empty())
    //cout<< "At line no : "<<" invalid "<<str<<endl;
    str="";

    line++;}
{WHITESPACE}|{ID}|{ALPHA}*|"," {
    str+=yytext;
}     
{GMAIL} {
    cout<<"At line no : "<<line<<" the valid gmail "<<yytext<<endl;
    str+=yytext;
}
{LINK} {
    cout<<"At line no : "<<line<<" the valid url "<<yytext<<endl;
    str+=yytext;
}
{INVALID_EMAIL0}|{INVALID_EMAIL1}|{INVALID_EMAIL2}|{INVALID_EMAIL3}|{INVALID_EMAIL4}|{INVALID_EMAIL5} {
   cout<<"At line no : "<<line<<" the invalid gmail "<<yytext<<endl;
}
{INVALID_URL0} {
  cout<<"At line no : "<<line<<" the invalid url "<<yytext<<endl;  
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