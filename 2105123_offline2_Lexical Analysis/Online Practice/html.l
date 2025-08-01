%option noyywrap
/*Problem 1: Nested HTML/XML Tag Validator

Task:
Write a lex program to validate nested HTML/XML tags (e.g., <div><p></p></div>) and detect:

    Mismatched tags (e.g., <div><p></div></p> → Error).

    Unclosed tags (e.g., <div><p></div> → Error).

    Self-closing tags (e.g., <img/> → Valid).

Output:

    Print "Valid" if tags are properly nested and closed.

    Print "Error: Unclosed <div>" or "Error: Mismatched <p>" otherwise.*/
%{
    #include<iostream>
    #include<string>
    #include<stdio.h>
    #include<stack>
    using namespace std;
    string str="";
    stack<string>st;
    int line=1;
    bool isok=true;


%}
WHITESPACE [ \t]+
ALPHA [a-zA-Z_]
DIGIT [0-9]
ID {ALPHA}({ALPHA}|{DIGIT})*
STARTPATTERN "<"{ID}">"
CLOSEDPATTERN "</"{ID}">"
ONEPATTERN "<"{ID}"/>"

%%
\n {
if(isok)    
cout<<"Line no : "<<line <<" The detected pattern is : "<< str <<endl;    
else
cout<<"Line no : "<<line <<" The invalid pattern is : "<< str <<endl;    
line++;
str="";
isok=true;
while(!st.empty())
st.pop();
}
{STARTPATTERN} {
string token(yytext);
string id = token.substr(1, token.length() - 2);
 cout<<id<<endl;
st.push(id);
str+=yytext;
}
{ONEPATTERN} {
    str+=yytext;
}
{CLOSEDPATTERN} {
   str+=yytext;
   string token(yytext);
   if(st.empty())
   {
    isok=false;
   }
   else{
      string id = token.substr(2, token.length() - 3); 
      cout<<id<<endl;
      if(st.top()==id)
      st.pop();
      else{
        isok=false;
      }
    //str+=yytext;
    
   }
}
<<EOF>> {
    if(isok)    
cout<<"Line no : "<<line <<" The detected pattern is : "<< str <<endl;    
else
cout<<"Line no : "<<line <<" The invalid pattern is : "<< str <<endl;  
    return 0;
}
.+ {
    isok = false;
    str += yytext;
}


%%
int main()
{
    yylex();
    return 0;

}