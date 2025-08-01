#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include "antlr4-runtime.h"
#include "C2105123Lexer.h"
#include "HEADER_SYMBOL_TABLE/2105123_HashFunction.hpp"
#include "HEADER_SYMBOL_TABLE/2105123_SymbolTable.hpp"
#include "C2105123Parser.h"

using namespace antlr4;
using namespace std;

ofstream parserLogFile; // global output stream
ofstream errorFile; // global error stream
ofstream lexLogFile; // global lexer log stream
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
bool do_start=false;

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
    cout << "Parsing completed. Check the output files for details." << endl;
    return 0;
}
