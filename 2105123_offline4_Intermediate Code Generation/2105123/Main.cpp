#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include "antlr4-runtime.h"
#include "C2105123Lexer.h"
#include "HEADER_SYMBOL_TABLE/2105123_HashFunction.hpp"
#include "HEADER_SYMBOL_TABLE/2105123_SymbolTable.hpp"
#include "optfile.cpp"
#include "C2105123Parser.h"

using namespace antlr4;
using namespace std;

ofstream parserLogFile; // global output stream
ofstream errorFile; // global error stream
ofstream lexLogFile; // global lexer log stream
ofstream code_asmFile;
//ofstream optimized_code_asmFile;
ofstream temp_codeFile;

SymbolTable smb_tb(7,&Hash::SDBMHash,true);

int syntaxErrorCount;
vector<string> global_arguement_list;
vector<pair<string,int>> global_variable_list;
vector<pair<string,string>> global_parameter_list;
vector<string>array_list;
vector<string>arguement_list;
bool func=false;
string type;
string func_name;
bool is_code_initialization=false;
int local_offset=0;
int global_offset=0;
int label_count=0;
int cond_label_cnt=0;
vector<int> true_label,false_label,exit_label,next_label;
map<string,string> label_map;
vector<string>true_list,false_list,unconditional_jump_list;
vector<int>start_label,condition_label,increment_label,statement_label,outside_label,jumping_true,jumping_false,jumping_unconditional,tmp_vector;
int tmp_label_cnt=0;
int tmp_label_cnt2=0,unconditional_jump=0;
int relational_assignment=0;
int logical_assignment=0;
string else_if_statement="";
string cur_file_name="";
bool else_if_statement_bool=false;
int loop_count=0;
int is_expression=0;
bool loop_if=false;
int logical_if_else=0;
bool non_relational_logical=false;
map<string,string>final_label_map; 
int final_label_map_count=0;

int main(int argc, const char* argv[]) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <input_file>" << endl;
        return 1;
    }

    // ---- Input File ----
    ifstream inputFile(argv[1]);
    if (!inputFile.is_open()) {
        cerr << "Error opening input file: " << argv[1] << endl;
        return 1;
    }

    string outputDirectory = "output/";
    string parserLogFileName = outputDirectory + "parserLog.txt";
    string errorFileName = outputDirectory + "errorLog.txt";
    string lexLogFileName = outputDirectory + "lexerLog.txt";
    string codeFileName= outputDirectory + "code.asm";
    string tempcodeFileName = outputDirectory + "code.txt";


    // create output directory if it doesn't exist
    system(("mkdir -p " + outputDirectory).c_str());

    // ---- Output Files ----
    parserLogFile.open(parserLogFileName);
    if (!parserLogFile.is_open()) {
        cerr << "Error opening parser log file: " << parserLogFileName << endl;
        return 1;
    }

    errorFile.open(errorFileName);
    if (!errorFile.is_open()) {
        cerr << "Error opening error log file: " << errorFileName << endl;
        return 1;
    }

    lexLogFile.open(lexLogFileName);
    if (!lexLogFile.is_open()) {
        cerr << "Error opening lexer log file: " << lexLogFileName << endl;
        return 1;
    }
    code_asmFile.open(codeFileName);
    if (!code_asmFile.is_open()) {
        cerr << "Error opening lexer log file: " << codeFileName << endl;
        return 1;
    }  
    // optimized_code_asmFile.open(optimizedcodeFileName);
    // if (!optimized_code_asmFile.is_open()) {
    //     cerr << "Error opening lexer log file: " << optimizedcodeFileName << endl;
    //     return 1;
    // }    
    temp_codeFile.open(tempcodeFileName);
    if (!temp_codeFile.is_open()) {
        cerr << "Error opening lexer log file: " << tempcodeFileName << endl;
        return 1;
    }        
    // ---- Parsing Flow ----
    ANTLRInputStream input(inputFile);
    C2105123Lexer lexer(&input);
    CommonTokenStream tokens(&lexer);
    C2105123Parser parser(&tokens);

    // this is necessary to avoid the default error listener and use our custom error handling
    parser.removeErrorListeners();

    // start parsing at the 'start' rule
    parser.start();

    // clean up
    inputFile.close();
    parserLogFile.close();
    errorFile.close();
    lexLogFile.close();
    code_asmFile.close();
    //optimized_code_asmFile.close();
    cout << "Parsing completed. Check the output files for details." << endl;
    optimizeAssembly(codeFileName, "output/opt_code.asm");

    return 0;
}
