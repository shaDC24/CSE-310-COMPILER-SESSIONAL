%option noyywrap

%{
#include <stdio.h>
%}
WHITESPACE [ \t\f\r\v]+
NEWLINE \n
DIGIT [0-9]
ALPHA [a-zA-Z_]
ID {ALPHA}({ALPHA}|{DIGIT})*
INT [-+]?{DIGIT}+
FLOAT [-+]?{DIGIT}+"."{DIGIT}+
SCIENTIFIC [-+]?{DIGIT}+(\.{DIGIT}+)?[eE][-+]?{DIGIT}+
NUMBER [-+]?({DIGIT}+(\.{DIGIT}+)?([eE][-+]?{DIGIT}+)?)
STRING \"[^\"]*\"
CHARACHTER \'([^\'\\]|\\.)\'
%%

"#define"[ \t]+{ID}[ \t]+({INT}|{SCIENTIFIC}) {
    printf("MACRO %s (MACRO WITH INT) DETECTED\n",yytext);
}
"#define"[ \t]+{ID}[ \t]+({FLOAT}|{SCIENTIFIC}) {
    printf("MACRO %s (MACRO WITH FLOAT) DETECTED\n",yytext);
}
"#define"[ \t]+{ID}[ \t]+{CHARACHTER} {
    printf("MACRO %s (MACRO WITH CHARACHTER) DETECTED\n",yytext);
}
"#define"[ \t]+{ID}[ \t]+{STRING} {
    printf("MACRO %s (MACRO WITH STRING) DETECTED\n",yytext);
}
.* {
    printf("Invalid MACRO : %s\n",yytext);
}
<<EOF>> {
    return 0;
}
.|\n     ;  
%%


int main() {
    yylex();
    return 0;
}
