%option noyywrap
%{
#include <iostream>
#include <stdio.h>
#include <stack>
#include <string>

using namespace std;

string current_pair = "";
stack<char> brace_stack;
int line = 1;
bool is_valid = true;
%}

WHITESPACE      [ \t\r]*
DIGIT           [0-9]
ALPHA           [a-zA-Z_]
NUMBER          -?{DIGIT}+(\.{DIGIT}+)?([eE][+-]?{DIGIT}+)?
STRING          \"([^"\\]|\\.)*\"
BOOL           (true|false|null)
VALUE           {STRING}|{NUMBER}|{BOOL}
KEY             {STRING}

%%

\n              { line++; }

{WHITESPACE}    { /* ignore whitespace */ }

"{"             { 
                  brace_stack.push('{'); 
                  current_pair.clear();
                }

"}"             {
                  if(brace_stack.empty() || brace_stack.top() != '{') {
                      is_valid = false;
                  } else {
                      brace_stack.pop();
                  }
                }

{KEY}{WHITESPACE}":"{WHITESPACE}{VALUE} {
                  cout << line<< " KEY: " << yytext << endl;
                  // Extract key and value properly here
                  // This is simplified - you'd need to split the match
                }

","             { /* handle comma between pairs */ }

.               { 
                 // cerr << "Error: Invalid character '" << yytext 
                   //    << "' at line " << line << endl;
                  is_valid = false;
                }

%%

int main() {
    yylex();
    if(!brace_stack.empty()) {
        cerr << "Error: Unmatched braces" << endl;
        is_valid = false;
    }
    cout << (is_valid ? "Valid JSON" : "Invalid JSON") << endl;
    return 0;
}
