%option noyywrap
%x CAMEL
%x SNAKE
%{
#include <stdio.h>
#include <string.h>

//char word[100];
//int idx = 1;
int has_underscore = 0;
int has_uppercase = 0;
int has_ws=0;
int c=0,s=0;
bool CHECK(const char *str)
{
    for(int i=0;str[i]!='\0';i++)
    {
        if(str[i]==' ' || str[i]=='_')
        return false;
    }
    return true;
}

bool CHECK2(const char *str)
{
    for(int i=0;str[i]!='\0';i++)
    {
        if(str[i]==' ')
          has_ws=1;
        if(str[i]=='_')
        {
            has_underscore =1;
        }
        if(str[i]>='A' && str[i]<='Z')
        has_uppercase=1;
    }
    if(has_underscore && !has_ws && !has_uppercase)
    return true;
return false;
}
int getLength(const char *str)
{
    int cnt=0;
    for(int i=0;str[i]!='\0';i++)
    {
        
        cnt+=1;
    }
    return cnt;
}
%}
WHITESPACE [ \t\f\r\v]+
NEWLINE \n


%%

[a-zA-Z][a-zA-Z0-9_]*   {
   if(getLength(yytext)>=2 && yytext[0]>='a' && yytext[0]<='z')
   {
    
    if(yytext[1]>='A' && yytext[1]<='Z')
    {if (CHECK(yytext))
    {
     c+=1;
    }}
    else{
   // has_underscore=0;    
    if(CHECK2(yytext))
    {
        s+=1;
    }
    }
    }
   
}
{NEWLINE} {
has_underscore=0;  
has_ws=0;
has_uppercase=0;
}
<<EOF>> {
    printf("Camel : %d\n Snake : %d\n",c,s);
    return 0;
}

.|\n                    ;  // ignore everything else

%%

int main() {
    yylex();
    return 0;
}
