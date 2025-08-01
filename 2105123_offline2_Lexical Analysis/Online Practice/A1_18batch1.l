%option noyywrap

%{
#include <stdio.h>
#include <iostream>
#include <stack>
#include <vector>
#include <string>
using namespace std;
FILE *logout;
stack<char> st;
string s="";
vector<string>names;
int line=1;
bool duplicat(string &str)
{
    for(int i=0;i<names.size();i++)
    {
        if(names[i]==str)
        {
            return true;
        }
    }
    return false;
}
%}

WHITESPACE [ \t\r]*
DIGIT [0-9]
ALPHA [a-zA-Z_]
ID {ALPHA}({ALPHA}|{DIGIT})*

%%
\n {
 if(!st.empty())
{
    fprintf(logout,"Line no : %d  Invalid pattern %s\n",line,s.c_str());
}
else{
    fprintf(logout,"Line no : %d  valid pattern %s\n",line,s.c_str());
}
line++;
s="";
while(!st.empty())
st.pop();
while(!names.empty())
names.pop_back();
}
{ID}{WHITESPACE}"<"{WHITESPACE} {
    string str(yytext,strlen(yytext)-1);
    if(names.empty()|| !duplicat(str))
    {
        names.push_back(str);
    }
    else if(duplicat(str))
    {
      fprintf(logout,"Line no : %d #Duplicate string found %s\n",line,yytext);
    }
    st.push('<');
    s+=yytext;
}
{ID} {
    string str(yytext,strlen(yytext));
    if(names.empty()|| !duplicat(str))
    {
        names.push_back(str);
    }
    else if(duplicat(str))
    {
      fprintf(logout,"Line no : %d #Duplicate string found %s\n",line,yytext);
    }
    //st.push('<');
    s+=yytext;  
}
{WHITESPACE}"<"{WHITESPACE} {
    st.push('<');
    s+=yytext;
}
{WHITESPACE}">"{WHITESPACE} {
    if(st.top()=='<')
    st.pop();
    s+=yytext;
}
<<EOF>> {
     if(!st.empty())
{
    fprintf(logout,"Line no : %d  Invalid pattern %s\n",line,s.c_str());
}
else{
    fprintf(logout,"Line no : %d  Mismatched pattern %s\n",line,s.c_str());
}
return 0;
}
%%


int main() {
    logout=fopen("logout.txt","w");
    yylex();
    return 0;
}
