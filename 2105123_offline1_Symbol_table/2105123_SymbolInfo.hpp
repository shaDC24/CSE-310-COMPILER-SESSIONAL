#ifndef SYMBOLINFO_HEADER
#define SYMBOLINFO_HEADER

#include <iostream>
#include <string>
using namespace std;

class SymbolInfo {
 private:
  string symbolName;
  string symbolType;
  SymbolInfo *nextSymbol;

 public:
  SymbolInfo(string symbolName, string symbolType) {
    this->symbolName = symbolName;
    this->symbolType = symbolType;
    this->nextSymbol = nullptr;
  }
  void setsymbolName(string symbolName) { this->symbolName = symbolName; }
  void setsymbolType(string symbolType) { this->symbolType = symbolType; }
  void setnextSymbol(SymbolInfo *nextSymbol) { this->nextSymbol = nextSymbol; }

  string getsymbolName() const { return this->symbolName; }
  string getSymbolType() const { return this->symbolType; }
  SymbolInfo *getnextSymbol() const { return this->nextSymbol; }
};

#endif