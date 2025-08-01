%option noyywrap
%x closing
%{
#include <iostream>    
#include <stdio.h>
#include <string>
using namespace std;
int count=0;
string txt="";
FILE *logout;
int line=1;
bool isextra=false;
%}

%%
\n {line++;}
"int"|"float"|"double"|"char" {
    if(count>0)
    {
      txt+=yytext;
      BEGIN closing;
    }
    else{
        fprintf(logout,"Line no : %d This is not nested vector starting... %s\n",line,yytext);
    }
}
"vector"[ \t]*"<"[ \t]* {
   txt+=yytext;
   count++;
}
">" {
    txt+=yytext;
    if(isextra)
    fprintf(logout, "Line no : %d Extra closing bracket: %s\n", line, txt.c_str());
}

<closing>[ \t]*">"[ \t]* {

        txt+=yytext;
        count--;
    
}
<closing>[\n] {
    //line++;
    if(count<0)
    {
        fprintf(logout,"Line no : %d In valid vector : %s\n", line,txt.c_str());
    }
    else{
        fprintf(logout,"Line no %d : the vector is  %s\n", line,txt.c_str());
    }
    line++;
    BEGIN INITIAL;
    count=0;
    txt="";
}
[^ \t\n<>;]+ {
    fprintf(logout,"Line no : %d : In valid vector : %s\n", line,yytext);
} 

<<EOF>> {
    return 0;
}
%%


int main() {
    logout = fopen("A1_log.txt", "w");
    if (!logout) {
        cerr << "Could not open log file!\n";
        return 1;
    }
    yylex();
    fclose(logout);
    return 0;
}
