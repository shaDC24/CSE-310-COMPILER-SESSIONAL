%option noyywrap


%{
#include <iostream>
#include <string>
//#include <vector>
int camel=0;
int snake=0;

%}
SNAKE [a-z]+(_[a-z0-9]+)+
CAMEL [a-z]+([A-Z][a-z0-9]*)+

%%
{SNAKE} {
snake+=1;
printf("string : %s",yytext);
}
{CAMEL} {
    camel+=1;
    printf("string : %s",yytext);
}
. {
}
<<EOF>> {
    printf("Camel : %d : Snake : %d \n",camel,snake);
    return 0;
}
%%


int main() {
    yylex();
    return 0;
}