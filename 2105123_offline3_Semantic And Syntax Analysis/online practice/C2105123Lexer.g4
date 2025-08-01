lexer grammar C2105123Lexer;

@lexer::header {
    #pragma once
    #include <iostream>
    #include <fstream>
    #include <string>

    extern std::ofstream lexLogFile;
}

@lexer::members {
    void writeIntoLexLogFile(const std::string &message) {
        if (!lexLogFile.is_open()) {
            lexLogFile.open("lexLogFile.txt", std::ios::app);
            if (!lexLogFile) {
                std::cerr << "Error opening lexLogFile.txt" << std::endl;
                return;
            }
        }
        lexLogFile << message << std::endl;
        lexLogFile.flush();
    }
}

// ------------------------------
// 1) Comments (skipped + logged)
// ------------------------------

// Single-line comments: '//' then anything except newline
LINE_COMMENT
    : '//' ~[\r\n]* {
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <SINGLE LINE COMMENT> Lexeme "
          + getText()
        );
    } -> skip
    ;

// Multi-line comments
BLOCK_COMMENT
  : '/*' ( . | '\r' | '\n' )*? '*/' {
      // extra braces create a new scope for your variables
      {
        std::string txt = getText();
        std::string content = txt.substr(2, txt.size() - 4);
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <MULTI LINE COMMENT> Lexeme /*"
          + content + "*/"
        );
      }
    }
    -> skip
  ;


// ------------------------------
// 2) String literals (skipped + logged)
// ------------------------------

// A basic string rule with escape support :contentReference[oaicite:5]{index=5}
STRING
    : '"' ( '\\' . | ~["\\\r\n] )* '"' {
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <STRING> Lexeme " + getText()
        );
    } 
    ;

// ------------------------------
// 3) Whitespace & Newlines (skipped)
// ------------------------------

WS      : [ \t\f\r\n]+ -> skip ;

// ------------------------------
// 4) Keywords & Symbols
// ------------------------------

IF       : 'if' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <IF> Lexeme " + getText()); };
ELSE     : 'else' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ELSE> Lexeme " + getText()); };
DO       : 'do' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <DO> Lexeme " + getText()); };     
FOR      : 'for' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <FOR> Lexeme " + getText()); };
FORIN    : 'forin' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <FORIN> Lexeme " + getText()); };
FOREACH  : 'foreach' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <FOREACH> Lexeme " + getText()); };
IN      : 'in' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <IN> Lexeme " + getText()); };
TO      : 'to' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <TO> Lexeme " + getText()); }; 
WHILE    : 'while' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <WHILE> Lexeme " + getText()); };
BREAK    : 'break' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <BREAK> Lexeme " + getText()); };
CONTINUE : 'continue' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <CONTINUE> Lexeme " + getText()); };
GOTO     : 'goto' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <GOTO> Lexeme " + getText()); };
PRINTLN  : 'printf' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <PRINTLN> Lexeme " + getText()); };
RETURN   : 'return' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RETURN> Lexeme " + getText()); };
INT      : 'int' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <INT> Lexeme " + getText()); };
FLOAT    : 'float' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <FLOAT> Lexeme " + getText()); };
VOID     : 'void' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <VOID> Lexeme " + getText()); };
TIMES    : 'times' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <TIMES> Lexeme " + getText()); };
SWITCH   : 'switch' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <SWITCH> Lexeme " + getText()); };
CASE     : 'case' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <CASE> Lexeme " + getText()); };
LOOP     : 'loop' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LOOP> Lexeme " + getText()); };
LPAREN   : '(' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LPAREN> Lexeme " + getText()); };
RPAREN   : ')' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RPAREN> Lexeme " + getText()); };
LCURL    : '{' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LCURL> Lexeme " + getText()); };
RCURL    : '}' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RCURL> Lexeme " + getText()); };
LTHIRD   : '[' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LTHIRD> Lexeme " + getText()); };
RTHIRD   : ']' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RTHIRD> Lexeme " + getText()); };
SEMICOLON: ';' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <SEMICOLON> Lexeme " + getText()); };
COLON    : ':' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <COLON> Lexeme " + getText()); };
QUESTION : '?' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <QUESTION> Lexeme " + getText()); };
COMMA    : ',' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <COMMA> Lexeme " + getText()); };
POINTER  : '*' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <POINTER> Lexeme " + getText()); };
STRUCT   : 'struct' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <STRUCT> Lexeme " + getText()); };
TRY      : 'try' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <TRY> Lexeme " + getText()); };
CATCH    : 'catch' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <CATCH> Lexeme " + getText()); };
EXCEPTION: 'exception' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <EXCEPTION> Lexeme " + getText()); };
UNDEFINED_TYPE : 'undefined_type' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <UNDEFINED_TYPE> Lexeme " + getText()); }; 
INLINE : 'inline' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <INLINE> Lexeme " + getText()); };
ENUM   : 'enum' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ENUM> Lexeme " + getText()); };
MALLOC : 'malloc' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <MALLOC> Lexeme " + getText()); };

ADDOP    : [+\-] { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ADDOP> Lexeme " + getText()); };
SUBOP    : [+\-] { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <SUBOP> Lexeme " + getText()); };
MULOP    : [*/%] { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <MULOP> Lexeme " + getText()); };
INCOP    : '++' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <INCOP> Lexeme " + getText()); };
DECOP    : '--' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <DECOP> Lexeme " + getText()); };
NOT      : '!' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <NOT> Lexeme " + getText()); };
RELOP    : '<=' | '==' | '>=' | '>' | '<' | '!=' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <RELOP> Lexeme " + getText()); };
LOGICOP  : '&&' | '||' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <LOGICOP> Lexeme " + getText()); };
ASSIGNOP : '=' { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ASSIGNOP> Lexeme " + getText()); };

// ------------------------------
// 5) Identifiers & Numbers
// ------------------------------

ID         : [A-Za-z_] [A-Za-z0-9_]* { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <ID> Lexeme " + getText()); };
CONST_INT  : [0-9]+ { writeIntoLexLogFile("Line# " + std::to_string(getLine()) + ": Token <CONST_INT> Lexeme " + getText()); };
CONST_FLOAT
    : [0-9]+ ('.' [0-9]*)? ([Ee][+\-]? [0-9]+)? {
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <CONST_FLOAT> Lexeme " + getText()
        );
    }
    | '.' [0-9]+ {
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <CONST_FLOAT> Lexeme " + getText()
        );
    }
    | [0-9]+ '.' {
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <CONST_FLOAT> Lexeme " + getText()
        );
    }
    ;

ERROR_CHAR
    : . {
        writeIntoLexLogFile(
          "Line# " + std::to_string(getLine())
          + ": Token <ERROR> Lexeme " + getText()
        );
    }
    ;
