%option noyywrap

%{
#include <iostream>
#include <stdio.h>
#include <string>
#include <stack>
using namespace std;
string str="";
FILE *logout;
stack<char>st;

%}

%%

[\(\)\{\}\[\]] {
    str+=yytext;
fprintf(logout,"%s is the sequence\n",yytext);
char c=yytext[0];
if(c=='(' || c=='{' || c=='[')
st.push(c);
else{
    if(!st.empty())
    {if((c==')' && st.top()=='(') || (c=='}' && st.top()=='{') || (c==']' && st.top()=='['))
    {
        st.pop();
    }

    }
    else{
        fprintf(logout,"Mismatched pattern : %s \n",str.c_str());
    }
}
}
\n {
    if(st.empty())
    {
        fprintf(logout,"Matched pattern : %s \n",str.c_str());
    }
    else
    {
        fprintf(logout,"Mismatched pattern : %s \n",str.c_str());
    }
    str="";
}
<<EOF>> {
     if(st.empty())
    {
        fprintf(logout,"Matched pattern : %s \n",str.c_str());
    }
    else
    {
        fprintf(logout,"Mismatched pattern : %s \n",str.c_str());
    }   
    return 0;
}
[ \t]+ {}
. {
 //fprintf(logout,"%s is not okay\n",yytext);   
}
%%


int main() {
    logout = fopen("B1_log.txt", "w");
    if (!logout) {
        cerr << "Could not open log file!\n";
        return 1;
    }
    yylex();
    fclose(logout);
    return 0;
}
