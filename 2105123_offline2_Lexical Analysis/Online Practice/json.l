/*Problem 3: JSON Key-Value Pair Extractor

Task:
Write a lex program to parse a simplified JSON string (e.g., {"name": "Alice", "age": 25}) and:

    Extract keys and values (strings/numbers).

    Detect missing commas (e.g., {"a":1 "b":2} → Error).

    Reject unquoted keys (e.g., {a: 1} → Error).

Output:

    Print each key-value pair (e.g., KEY: name, VALUE: "Alice").

    Print errors for invalid syntax.*/

%option noyywrap
%x T
%{
 #include <iostream>
 #include <stdio.h>
 #include <stack>
 #include <string>   

 string str="";
 stack<char>st;
 int line=1;
 boll isok=true;
%}
WHITESPACE [ \t\r]*
DIGIT [0-9]
ALPHA [a-zA-Z_]
SPECIALCHAR [@$#]
ID {SPECIALCHAR}*{ALPHA}+({DIGIT}|{ALPHA}|{SPECIALCHAR})*
INT {DIGIT}+{DIGIT}*
FLOAT {DIGIT}+(\.{DIGIT}+)*
NEG [-]({INT}|{FLOAT})
EXP [-+]?({INT}|{FLOAT})[eE]{INT}+
BOOL ["true"|"false"|"null"]
STR [\"{ID}\"]
ARRAY \[({ID}|{NEG}|{INT}|{FLOAT}|{EXP}|{BOOL}|{STR})(","({ID}|{NEG}|{INT}|{FLOAT}|{EXP}|{BOOL}|{STR})+)* \]
ID2 {ID}|{NEG}|{INT}|{FLOAT}|{EXP}|{BOOL}|{STR}|{ARRAY}

%%
\n {line++;}
{WHITESPACE}"{"{WHITESPACE} {
    st.push('{');
    str+=yytext;
} 
{WHITESPACE}"}"{WHITESPACE} {
    if(st.empty())
    {
        isok=false;
    }
    else if(st.top()=='}')
    {
        st.pop();
    }
    str+=yytext;
}
{WHITESPACE}\"{ID}\"{WHITESPACE}:{WHITESPACE}\"{ID2}\"{WHITESPACE} {
str+=yytext;
BEGIN T;
}
{WHITESPACE}\"{ID}\"{WHITESPACE}:{WHITESPACE}{ID2}{WHITESPACE} {
str+=yytext;
BEGIN T;
}
<T>,{WHITESPACE}\"{ID}\"{WHITESPACE}:{WHITESPACE}\"{ID2}\"{WHITESPACE} {
str+=yytext;
}
<T>,{WHITESPACE}\"{ID}\"{WHITESPACE}:{WHITESPACE}{ID2}{WHITESPACE} {
str+=yytext;
}
<T>{WHITESPACE}"}"{WHITESPACE} {
    if(st.empty())
    {
        isok=false;
    }
    else if(st.top()=='}')
    {
        st.pop();
    }
    str+=yytext;
}
<T>\n {
    if(!st.empty())
    {
        isok=false;
    }
if(isok)
    cout<<"Line no : "<<line<<"The pattern is : "<<str<<endl;
else{
    cout<<"Line no : "<<line<<"The invalid pattern is : "<<str<<endl;
}
    BEGIN INITIAL;
    str="";
    while(!st.empty()) st.pop();

}
.+ {
    isok=false;
    str+=yytext;
}

%%
int main()
{
    yylex();
    return 0;
}
