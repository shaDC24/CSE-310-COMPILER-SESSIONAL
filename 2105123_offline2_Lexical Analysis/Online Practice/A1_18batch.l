%option noyywrap


%{
#include <iostream>
#include <string>
#include <vector>


std::string currentTemplate = "";
std::vector<std::string> templateNames;
int angleCount = 0;

void resetTemplateTracking()
{
    angleCount =0;
    templateNames.clear();
    currentTemplate = "";
}

// Function to check if a name already exists in the template names vector
bool isDuplicateName(const std::string& name) {
    for (const auto& tName : templateNames) {
        if (tName == name) {
            return true;
        }
    }
    return false;
}
%}

WHITESPACE [ \t\n\r]+
LETTER [a-zA-Z]
DIGIT [0-9]
IDENTIFIER {LETTER}({LETTER}|{DIGIT}|_)*

%%

{IDENTIFIER}"<" {
    // Extract template name (without the <)
    std::string name(yytext, strlen(yytext)-1);
    
    if (angleCount == 0) {
        // Start of a new template
        currentTemplate = yytext;
        angleCount = 1;
        templateNames.push_back(name);
    } else {
        // Nested template
        currentTemplate += yytext;
        angleCount++;
        
        // Check if this name is a duplicate
        if (isDuplicateName(name)) {
            printf("Error: Invalid template - duplicate name '%s'\n", name.c_str());
        } else {
            templateNames.push_back(name);
        }
    }
    std::cout<<name<<std::endl;
}

"<" {
    if (angleCount > 0) {
        angleCount++;
        currentTemplate += yytext;
    }
}

">" {
    if (angleCount > 0) {
        angleCount--;
        currentTemplate += yytext;
        
        if (angleCount == 0) {
            // Template is complete
            printf("Template %s detected\n", currentTemplate.c_str());
            resetTemplateTracking();
        }
    }
}

{IDENTIFIER} {
    std::string name(yytext);
    if (angleCount > 0) {
        currentTemplate += yytext;
        if (isDuplicateName(name)) {
            printf("Error: Invalid template - duplicate name '%s'\n", name.c_str());
        } else {
            templateNames.push_back(name);
        }
    }
    std:: cout<< yytext << std:: endl;
}

{WHITESPACE} {
    if (angleCount > 0) {
        printf("Error: Unfinished Template %s\n", currentTemplate.c_str());
        resetTemplateTracking();
    }
}

. {
    if (angleCount > 0) {
        currentTemplate += yytext;
    }
}

<<EOF>> {
    if (angleCount > 0) {
        printf("Error: Unfinished Template %s\n", currentTemplate.c_str());
        resetTemplateTracking();
    }
    return 0;
}

%%

int main() {
    yylex();
    return 0;
}