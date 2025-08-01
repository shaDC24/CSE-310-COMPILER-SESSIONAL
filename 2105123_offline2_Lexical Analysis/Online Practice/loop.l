/*Problem 5: Nested Loop Pattern Detector

Task:
Write a lex program to detect nested loops in C code (e.g., for (...) { while (...) { ... } }) and:

    Count nesting depth (e.g., depth=2 for the above example).

    Detect unmatched braces (e.g., for (...) { while (...) { ... } → Error).

Output:

    Print loop nesting depth.

    Print errors for unbalanced braces.*/

%option noyywrap

%{
#include <iostream>
#include <stack>
#include <vector>
using namespace std;

stack<char> brace_stack;
vector<string> loop_types;
vector<int> loop_depths;
stack<int> depth_stack;  // To track depth for each brace level

int current_depth = 0;
int max_depth = 0;
int line = 1;
bool expect_brace = false;

void handle_loop(const char* type) {
    loop_types.push_back(type);
    loop_depths.push_back(current_depth);
}

void print_loop_info() {
    cout << "\nLoop Nesting Report:\n";
    cout << "Maximum depth: " << max_depth << "\n\n";
    
    cout << "Individual loops:\n";
    for (int i = 0; i < loop_types.size(); i++) {
        cout << i+1 << ". Type: " << loop_types[i] 
             << ", Depth: " << loop_depths[i]+1 << "\n";
    }
}
%}

%%
\n { line++; }

"for"    { 
    handle_loop("for"); 
    expect_brace = true;
}

"while"  { 
    handle_loop("while"); 
    expect_brace = true;
}

"do"     { 
    handle_loop("do-while"); 
    expect_brace = true;
}

"{"     {
    brace_stack.push('{');
    depth_stack.push(current_depth);
    if (expect_brace) {
        current_depth++;
        if (current_depth > max_depth) max_depth = current_depth;
    }
    expect_brace = false;
}

"}"     {
    if (brace_stack.empty()) {
        cout << "Error (Line " << line << "): Extra '}'\n";
    } else {
        brace_stack.pop();
        current_depth = depth_stack.top();
        depth_stack.pop();
    }
    expect_brace = false;
}

";"     { expect_brace = false; }

.       {}

<<EOF>> {
    if (!brace_stack.empty()) {
        cout << "Error: Unmatched '{' at EOF\n";
    }
    print_loop_info();
    return 0;
}
%%

int main() {
    yylex();
    return 0;
}