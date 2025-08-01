%option noyywrap
%x TEMPLATE

%{
#include <iostream>
#include <stack>
#include <string>
using namespace std;

stack<char> angleStack;
string str="";
int line=1;
bool iscor=true;
%}

IDENTIFIER [a-zA-Z_][a-zA-Z_0-9]*

%%

{IDENTIFIER}"<" {
    //cout << "Template Start: " << yytext << endl;
    angleStack.push('<');
    str+=yytext;
    BEGIN(TEMPLATE);
}
<TEMPLATE>{IDENTIFIER} {
    str+=yytext;
}
<TEMPLATE>"<" {
    angleStack.push('<');
    str+=yytext;
}
<TEMPLATE>">" {
    if(angleStack.empty())
    {
        cout<<"Line no : "<<line<<" Not correct pattern : "<< str <<endl;
        iscor=false;
        BEGIN INITIAL;
        str="";

    }
    else if(angleStack.top()=='<')
    { angleStack.pop();
      str+=yytext;
    }
}
<TEMPLATE>"," {
    str+=yytext;
}
<TEMPLATE>\n {
if(iscor)    
cout<<"Line no : "<< line << "  Detected pattern : "<<str<<endl;    
BEGIN INITIAL;
str="";
while(!angleStack.empty())
angleStack.pop();
line++;
iscor=true;
}
\n {
if(iscor)     
cout<<"Line no : "<< line << "  Detected pattern : "<<str<<endl;    
BEGIN INITIAL;
str="";
while(!angleStack.empty())
angleStack.pop();
line++;
iscor=true;
}
<<EOF>> {
    return 0;
}

%%

int main() {
    yylex();
    return 0;
}
