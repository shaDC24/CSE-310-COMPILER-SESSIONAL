%option noyywrap


%x TokenIZING_STRING
%x TokenIZING_SLASH_COMMENT
%x TokenIZING_STAR_COMMENT

%{
#include<iostream>
#include<algorithm>
#include<string>
#include"HEADER_SYMBOL_TABLE/2105123_SymbolTable.hpp"

using namespace std;

int total_lines=1;
int state_line_count=0;
int total_errors=0;
FILE *logout;
FILE *Tokenout;

SymbolTable symboltable(7,&Hash::SDBMHash,false);

string str1,str2,command_str;



void KEYWORD_CAPITALIZATION(const char* keyword_string) {
    char Token[100];
    int i;
    for (i = 0; keyword_string[i]; i++) {
        Token[i] = toupper(keyword_string[i]);
    }
    Token[i] = '\0';

    fprintf(Tokenout, "<%s> ", Token);
    fprintf(logout, "Line no %d: Token <%s> Lexeme %s found\n\n", total_lines, Token, keyword_string);
}

void INSERTED_ALREADY(const char* str,const char*type)
{
    ScopeTable *table=symboltable.getCurrrentScopeTable();
    fprintf(logout,"< %s : %s > already exists in ScopeTable# %s at position %d, %d\n\n",str,type,table->getTable(),table->getPositionIndex(),table->getChainIndex());
}


void CONSTANT_CHARACHTER_TokenIZATION(const char* const_char_string) {
    char actual_char;

    if (strcmp(const_char_string, "'\\n'") == 0)         actual_char = (char)10;  
    else if (strcmp(const_char_string, "'\\t'") == 0)    actual_char = (char)9;   
    else if (strcmp(const_char_string, "'\\\\'") == 0)   actual_char = (char)92;  
    else if (strcmp(const_char_string, "'\\\''") == 0)   actual_char = (char)39;  
    else if (strcmp(const_char_string, "'\\a'") == 0)    actual_char = (char)7;   
    else if (strcmp(const_char_string, "'\\f'") == 0)    actual_char = (char)12;  
    else if (strcmp(const_char_string, "'\\r'") == 0)    actual_char = (char)13;  
    else if (strcmp(const_char_string, "'\\b'") == 0)    actual_char = (char)8;   
    else if (strcmp(const_char_string, "'\\v'") == 0)    actual_char = (char)11;  
    else if (strcmp(const_char_string, "'\\0'") == 0)    actual_char = (char)0;   
    else if (strlen(const_char_string) == 3 && 
             const_char_string[0] == '\'' && const_char_string[2] == '\'') {
        actual_char = const_char_string[1];  
    }
    else actual_char = '?';

    if (actual_char != '?') {
        fprintf(Tokenout, "<CONST_CHAR, %c> ", actual_char);
        fprintf(logout, "Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CONST_CHAR, %c>\n\n", total_lines, const_char_string, actual_char);

        if (!symboltable.Insert(const_char_string, "CONST_CHAR")) {
            INSERTED_ALREADY(const_char_string, "CONST_CHAR");
        } else {
            symboltable.PrintAllScopeTable(logout);
        }
    }
}



void HANDLE_ESCAPED_STRING(const char* escaped_string) {
    str1 += escaped_string;

    if (strcmp(escaped_string, "\\n") == 0) str2 += '\n';
    else if (strcmp(escaped_string, "\\t") == 0) str2 += '\t';
    else if (strcmp(escaped_string, "\\\\") == 0) str2 += '\\';
    else if (strcmp(escaped_string, "\\\'") == 0) str2 += '\'';
    else if (strcmp(escaped_string, "\\\"") == 0) str2 += '\"';
    else if (strcmp(escaped_string, "\\a") == 0) str2 += '\a';
    else if (strcmp(escaped_string, "\\f") == 0) str2 += '\f';
    else if (strcmp(escaped_string, "\\r") == 0) str2 += '\r';
    else if (strcmp(escaped_string, "\\b") == 0) str2 += '\b';
    else if (strcmp(escaped_string, "\\v") == 0) str2 += '\v';
    else if (strcmp(escaped_string, "\\0") == 0) str2 += '\0';
    else str2 += '?'; 
}



%}

WHITESPACE [ \t\f\r\v]+
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
TOOMANYDECIMAL {DIGIT}*"."{DIGIT}*"."({DIGIT}|".")*
ILLFORMEDNUMBER {DIGIT}*("."{DIGIT}+)?("E"[-]?{DIGIT}*"."{DIGIT}*) 
INVALIDSUFFIXONNUMERIC {DIGIT}+({LETTER}|_)({LETTER}|{DIGIT}|_)+ 
MULTICHARACHTERCONSTANTERROR '{LETTER}[^\n]+'
UNFINISHEDCHARACHTER '\\'|'\\[nt\\afrbv0]|'[^\'\n]*
EMPTYCHARACHTERCONSTANTERROR ''
%%
{WHITESPACE} {}
{NEWLINE} {total_lines++;}


"if"|"for"|"do"|"int"|"float"|"void"|"switch"|"default"|"else"|"while"|"break"|"char"|"double"|"return"|"case"|"continue"|"goto"|"long"|"short"|"static"|"unsigned" {
	   KEYWORD_CAPITALIZATION(yytext);		
	}
"+"|"-" {
    fprintf(Tokenout, "<ADDOP, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <ADDOP> Lexeme %s found\n\n", total_lines, yytext);       
    }    
"*"|"/"|"%" {
    fprintf(Tokenout, "<MULOP, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <MULOP> Lexeme %s found\n\n", total_lines, yytext);          
    }  
"++"|"--" {
    fprintf(Tokenout, "<INCOP, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <INCOP> Lexeme %s found\n\n", total_lines, yytext);         
    }
"<"|"<="|">"|">="|"=="|"!=" {
    fprintf(Tokenout, "<RELOP, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <RELOP> Lexeme %s found\n\n", total_lines, yytext);  
    }   
"=" {
    fprintf(Tokenout, "<ASSIGNOP, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <ASSIGNOP> Lexeme %s found\n\n", total_lines, yytext); 
    }  
"&&"|"||" {
    fprintf(Tokenout, "<LOGICOP, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <LOGICOP> Lexeme %s found\n\n", total_lines, yytext);         
    } 
"!" {
    fprintf(Tokenout, "<NOT, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <NOT> Lexeme %s found\n\n", total_lines, yytext);         
    } 
"(" {
    fprintf(Tokenout, "<LPAREN, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <LPAREN> Lexeme %s found\n\n", total_lines, yytext);         
    }    
")" {
    fprintf(Tokenout, "<RPAREN, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <RPAREN> Lexeme %s found\n\n", total_lines, yytext);         
    } 
"{" {
    fprintf(Tokenout, "<LCURL, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <LCURL> Lexeme %s found\n\n", total_lines, yytext);  
    symboltable.EnterScope();        
    }    
"}" {
    fprintf(Tokenout, "<RCURL, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <RCURL> Lexeme %s found\n\n", total_lines, yytext);  
    symboltable.ExitScope();        
    } 
"[" {
    fprintf(Tokenout, "<LTHIRD, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <LTHIRD> Lexeme %s found\n\n", total_lines, yytext);         
    }   
"]" {
    fprintf(Tokenout, "<RTHIRD, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <RTHIRD> Lexeme %s found\n\n", total_lines, yytext);         
    }
"," {
    fprintf(Tokenout, "<COMMA, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <COMMA> Lexeme %s found\n\n", total_lines, yytext);         
    }  
";" {
    fprintf(Tokenout, "<SEMICOLON, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <SEMICOLON> Lexeme %s found\n\n", total_lines, yytext);         
    }          
{DIGIT}+ {
    fprintf(Tokenout, "<CONST_INT, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <CONST_INT> Lexeme %s found\n\n", total_lines, yytext);    
    if(!symboltable.Insert(yytext,"CONST_INT"))
    {
        INSERTED_ALREADY(yytext,"CONST_INT");
    }
    else{
        symboltable.PrintAllScopeTable(logout);
    }       
    }
{DIGIT}*("."{DIGIT}+)?("E"[-]?{DIGIT}+)? {
    fprintf(Tokenout, "<CONST_FLOAT, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <CONST_FLOAT> Lexeme %s found\n\n", total_lines, yytext);    
    if(!symboltable.Insert(yytext,"CONST_FLOAT"))
    {
        INSERTED_ALREADY(yytext,"CONST_FLOAT");
    }
    else{
        symboltable.PrintAllScopeTable(logout);
    }         
    }
({LETTER}|_)({LETTER}|_|{DIGIT})* {
    fprintf(Tokenout, "<ID, %s> ", yytext);
    fprintf(logout, "Line no %d: Token <ID> Lexeme %s found\n\n", total_lines, yytext);    
    if(!symboltable.Insert(yytext,"ID"))
    {
        INSERTED_ALREADY(yytext,"ID");
    }
    else{
        symboltable.PrintAllScopeTable(logout);
    }         
    }
'{LETTER}' {
        CONSTANT_CHARACHTER_TokenIZATION(yytext);
    }    
'\\n'|'\\t'|'\\\\'|'\\\''|'\\a'|'\\f'|'\\r'|'\\b'|'\\v'|'\\0' {
        CONSTANT_CHARACHTER_TokenIZATION(yytext);
    }  
\" {
    str1 = "\"";
    str2 = "";
    state_line_count = 0;
    BEGIN TokenIZING_STRING;
}
<TokenIZING_STRING>\\n|\\t|\\\\|\\\'|\\\"|\\a|\\f|\\r|\\b|\\v|\\0 {
       HANDLE_ESCAPED_STRING(yytext); 
    }        
<TokenIZING_STRING>\\\r\n {
		state_line_count++;
		str1 += "\\\r\n"; 
    }
<TokenIZING_STRING>\\\n {
		state_line_count++;
		str1 += "\\\n"; 
    }   

<TokenIZING_STRING>\" {
        total_lines= state_line_count+ total_lines;
        state_line_count= 0;       
		str1 += "\""; 
        str2 += ""; 
        fprintf(logout, "Line no %d: Token <STRING> Lexeme %s found --> <STRING, %s>\n\n", total_lines, str1.c_str(), str2.c_str());
        fprintf(Tokenout,"<STRING, %s> ",str2.c_str());
		BEGIN INITIAL;	
    }
<TokenIZING_STRING>[\r]?\n {
		total_errors++;
        fprintf(logout, "Error at line no %d: Unterminated string %s\n\n", total_lines, str1.c_str());
        state_line_count++;
        total_lines= state_line_count+ total_lines;
        state_line_count= 0;
		BEGIN INITIAL;	
    }
<TokenIZING_STRING>. {
        str1+=yytext[0];
        str2+=yytext[0];
    } 
\/\/ {
        command_str.clear();
        state_line_count=0;
        command_str+="//";
        BEGIN TokenIZING_SLASH_COMMENT;
    }
<TokenIZING_SLASH_COMMENT>\\\r\n {
        state_line_count++;
        command_str+="\\\r\n";
    }       
<TokenIZING_SLASH_COMMENT>\\\n {
        state_line_count++;
        command_str+="\\\n";
    }  
<TokenIZING_SLASH_COMMENT>\\ {
        command_str+="\\";
    } 


<TokenIZING_SLASH_COMMENT>[\r]?\n {
        //state_line_count++;
        total_lines += state_line_count;
        fprintf(logout,"Line no %d: Token <COMMENT> Lexeme %s found\n\n", total_lines, command_str.c_str());
        state_line_count++;
        total_lines += 1;
        command_str.clear();
        state_line_count = 0;
        BEGIN INITIAL;
}

    
<TokenIZING_SLASH_COMMENT><<EOF>> {
        total_lines= state_line_count+ total_lines;
        state_line_count= 0;     
  
        fprintf(logout,"Line no %d: Token <COMMENT> Lexeme %s found\n\n",total_lines,command_str.c_str());
		BEGIN INITIAL;        
    } 
<TokenIZING_SLASH_COMMENT>. {
        command_str+=yytext[0];
    } 
\/\* {
    command_str.clear();

     
     state_line_count= 0; 
     command_str="/*";
     BEGIN TokenIZING_STAR_COMMENT;

}  
<TokenIZING_STAR_COMMENT>[\r]?\n {
    
    state_line_count++;
    command_str+="\n";
}     
<TokenIZING_STAR_COMMENT>\*\/ {
        total_lines= state_line_count+ total_lines;
        state_line_count= 0;  
        command_str+="*/";  
        fprintf(logout,"Line no %d: Token <COMMENT> Lexeme %s found\n\n",total_lines,command_str.c_str());

		BEGIN INITIAL;          
    }  
<TokenIZING_STAR_COMMENT><<EOF>> {
        fprintf(logout,"Error at line no %d: Unterminated comment %s\n\n",total_lines,command_str.c_str());
        total_lines= state_line_count+ total_lines;
        state_line_count= 0;    
        total_errors++;        

		BEGIN INITIAL;          
    }                                    
<TokenIZING_STAR_COMMENT>. {
        command_str+=yytext[0];
    } 
{TOOMANYDECIMAL} {
        total_errors++;
        fprintf(logout, "Error at line no %d: Too many decimal points %s\n\n\n",total_lines , yytext); 
    } 
{ILLFORMEDNUMBER} {
        total_errors++;
         fprintf(logout, "Error at line no %d: Ill formed number %s\n\n\n", total_lines, yytext); 

    }      
{INVALIDSUFFIXONNUMERIC} {
        total_errors++;
        fprintf(logout, "Error at line no %d: Invalid prefix on ID or invalid suffix on Number %s\n\n", total_lines, yytext);        
    }
{MULTICHARACHTERCONSTANTERROR} {
       total_errors++;
        fprintf(logout, "Error at line no %d: Multi character constant error %s\n\n\n", total_lines, yytext);        
    }
{UNFINISHEDCHARACHTER} {
       total_errors++;
       fprintf(logout, "Error at line no %d: Unterminated character %s\n\n\n", total_lines, yytext);        
    }
{EMPTYCHARACHTERCONSTANTERROR} {
       total_errors++;
        fprintf(logout, "Error at line no %d: Empty character constant error %s\n\n\n", total_lines, yytext);        
    }
. {
    total_errors++;
    fprintf(logout, "Error at line no %d: Unrecognized character %s\n\n", total_lines, yytext);
}
   
    
%%

int main(int argc, char *argv[]) {
    if (argc != 2) {
        cout<<"The given command line format is incorrect" <<endl;
        cout << "Usage: " << argv[0] << " <input_file_name>" << endl;
        return 1;
    }

    FILE *fin = fopen(argv[1], "r");
    if (fin == NULL) {
        cout << "Error opening input file: " << argv[1] << endl;
        return 1;
    }

    logout = fopen("2105123_log.txt", "w");
    Tokenout = fopen("2105123_token.txt", "w");

    if (logout == NULL || Tokenout == NULL) {
        cout << "Error opening output files." << endl;
        fclose(fin);
        return 1;
    }

    yyin = fin;
    yylex();

    symboltable.PrintAllScopeTable(logout);
    fprintf(logout, "Total lines: %d\n", total_lines);
    fprintf(logout, "Total errors: %d\n", total_errors);

    fclose(fin);
    fclose(Tokenout);
    fclose(logout);

    return 0;
}
