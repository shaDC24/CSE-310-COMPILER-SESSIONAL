#ifndef SYMBOLINFO_HEADER
#define SYMBOLINFO_HEADER


#include <iostream>
#include <string>
#include "2105123_Extra_Info_SymbolInfo.hpp"
using namespace std;

class FunctionInfo {
private:
    string returnType;
    vector<pair<string, string>> parameters; 
    bool isDefined;
    bool isDeclared;
    
public:
    FunctionInfo() : isDefined(false), isDeclared(false) {}
    
    FunctionInfo(string retType) : returnType(retType), isDefined(false), isDeclared(false) {}

    string getReturnType() const { return returnType; }
    vector<pair<string, string>> getParameters() const { return parameters; }
    int getParameterCount() const { return parameters.size(); }
    bool getIsDefined() const { return isDefined; }
    bool getIsDeclared() const { return isDeclared; }

    void setReturnType(string retType) { returnType = retType; }
    void setIsDefined(bool defined) { isDefined = defined; }
    void setIsDeclared(bool declared) { isDeclared = declared; }
    
    void addParameter(string type, string name) {
        parameters.push_back(make_pair(type, name));
    }
    
    void clearParameters() {
        parameters.clear();
    }
    
    string getParameterType(int index) const {
        if (index >= 0 && index < parameters.size()) {
            return parameters[index].first;
        }
        return "";
    }
    
    string getParameterName(int index) const {
        if (index >= 0 && index < parameters.size()) {
            return parameters[index].second;
        }
        return "";
    }
};

class SymbolInfo {
 private:
  string symbolName;
  string symbolType;
  SymbolInfo *nextSymbol;
  ExtraSymbolInfo *extrainfo;

    string dataType;       
    bool isArray;        
    int arraySize;       
    bool isFunction;      
    FunctionInfo *funcInfo; 

 public:
  // SymbolInfo(string symbolName, string symbolType) {
  //   this->symbolName = symbolName;
  //   this->symbolType = symbolType;
  //   this->nextSymbol = nullptr;
  //   this->extrainfo=nullptr;
  // }
    SymbolInfo(string symbolName, string symbolType) {
        this->symbolName = symbolName;
        this->symbolType = symbolType;
        this->nextSymbol = nullptr;
        this->isArray = false;
        this->arraySize = 0;
        this->isFunction = false;
        this->funcInfo = nullptr;
        this->dataType = "";
        this->extrainfo=nullptr;
    }
  SymbolInfo(string symbolName, string symbolType, string returnType, int numParams) {
        this->symbolName = symbolName;
        this->symbolType = symbolType;
        this->nextSymbol = nullptr;
        this->extrainfo = new ExtraSymbolInfo(returnType, numParams);
        this->isArray = false;
        this->arraySize = 0;
        this->isFunction = false;
        this->funcInfo = nullptr;
        this->dataType = "";
    } 

  // SymbolInfo(string symbolName, string symbolType, string returnType, int numParams, param* params) {
  //       this->symbolName = symbolName;
  //       this->symbolType = symbolType;
  //       this->nextSymbol = nullptr;
  //       this->extrainfo = new ExtraSymbolInfo(returnType, numParams, params);
  //   }  
  // SymbolInfo(const SymbolInfo& other) {
  //       symbolName = other.symbolName;
  //       symbolType = other.symbolType;
  //       nextSymbol = nullptr;
  //       if (other.extrainfo != nullptr)
  //           extrainfo = new ExtraSymbolInfo(*other.extrainfo);
  //       else
  //           extrainfo = nullptr;
  //   }
//   SymbolInfo& operator=(const SymbolInfo& other) {
//         if (this != &other) {
//             symbolName = other.symbolName;
//             symbolType = other.symbolType;
//             delete extrainfo;
//             if (other.extrainfo != nullptr)
//                 extrainfo = new ExtraSymbolInfo(*other.extrainfo);
//             else
//                 extrainfo = nullptr;
//         }
//         return *this;
//     } 
SymbolInfo& operator=(const SymbolInfo& other) {
    if (this != &other) {
        symbolName = other.symbolName;
        symbolType = other.symbolType;
        dataType = other.dataType;
        isArray = other.isArray;
        arraySize = other.arraySize;
        isFunction = other.isFunction;
        
        // Clean up existing extrainfo
        delete extrainfo;
        if (other.extrainfo != nullptr) {
            extrainfo = new ExtraSymbolInfo(*other.extrainfo);
        } else {
            extrainfo = nullptr;
        }
        
        // FIX: Handle funcInfo properly
        delete funcInfo;  // Clean up existing funcInfo
        if (other.funcInfo != nullptr) {
            funcInfo = new FunctionInfo(*other.funcInfo);
        } else {
            funcInfo = nullptr;
        }
        
        // Don't copy nextSymbol - it's a linked list pointer
        nextSymbol = nullptr;
    }
    return *this;
}
  // ~SymbolInfo()
  // {
  //   delete extrainfo;
  // }   


    // Copy constructor
    SymbolInfo(const SymbolInfo& other) {
        this->symbolName = other.symbolName;
        this->symbolType = other.symbolType;
        this->nextSymbol = nullptr; // Don't copy the chain
        this->dataType = other.dataType;
        this->isArray = other.isArray;
        this->arraySize = other.arraySize;
        this->isFunction = other.isFunction;
        
        // Deep copy function info if exists
        if (other.funcInfo != nullptr) {
            this->funcInfo = new FunctionInfo(*other.funcInfo);
        } else {
            this->funcInfo = nullptr;
        }
        if (other.extrainfo != nullptr)
            extrainfo = new ExtraSymbolInfo(*other.extrainfo);
        else
            extrainfo = nullptr;        
    }
    
    // Destructor
    ~SymbolInfo() {
        if (funcInfo != nullptr) {
            delete funcInfo;
        }
        if(extrainfo!=nullptr)
        {
          delete extrainfo;
        }
    }
  void setsymbolName(string symbolName) { this->symbolName = symbolName; }
  void setsymbolType(string symbolType) { this->symbolType = symbolType; }
  void setnextSymbol(SymbolInfo *nextSymbol) { this->nextSymbol = nextSymbol; }
    void setReturnType(string returnType) {
        if (!extrainfo) extrainfo = new ExtraSymbolInfo();
        extrainfo->setReturnType(returnType);
    }

    void setNumberOfParameters(int numParams) {
        if (!extrainfo) extrainfo = new ExtraSymbolInfo();
        extrainfo->setNumberOfParameters(numParams);
    }

    // void setParameterList(param* params, int numParams) {
    //     if (!extrainfo) extrainfo = new ExtraSymbolInfo();
    //     extrainfo->setParameterList(params, numParams);
    // }  
    void addPara(string name="",string type="")
    {
      extrainfo->addPara(name,type);
    }
    void addParameters(param &parameter)
    {
      extrainfo->addParameter(parameter);
    }
    void removeParameters(int index)
    {
      extrainfo->removeParameter(index);
    }

  string getsymbolName() const { return this->symbolName; }
  string getSymbolType() const { return this->symbolType; }
  SymbolInfo *getnextSymbol() const { return this->nextSymbol; }
  ExtraSymbolInfo* getExtraSymbolInfo() const {
        return extrainfo;
    }  
    string getReturnType() const {
        if (!extrainfo) return "";
        return extrainfo->getReturnType();
    }

    int getNumberOfParameters() const {
        if (!extrainfo) return 0;
        return extrainfo->getNumberOfParameters();
    }

    vector<param> getParameterList() const {
        if (!extrainfo) return {};
        return extrainfo->getParameterList();
    }   
    
param *getParam(int index) {
    if (extrainfo != nullptr && index >= 0 && index < getNumberOfParameters()) {
        return &extrainfo->getParameterList()[index];
    }
    return nullptr;
}
    void setDataType(string dataType) { this->dataType = dataType; }
    string getDataType() const { return this->dataType; }
    
    void setIsArray(bool isArray) { this->isArray = isArray; }
    bool getIsArray() const { return this->isArray; }
    
    void setArraySize(int size) { this->arraySize = size; }
    int getArraySize() const { return this->arraySize; }
    
    void setIsFunction(bool isFunction) { this->isFunction = isFunction; }
    bool getIsFunction() const { return this->isFunction; }
    
    void initializeAsFunction(string returnType) {
        this->isFunction = true;
        if (this->funcInfo == nullptr) {
            this->funcInfo = new FunctionInfo(returnType);
        } else {
            this->funcInfo->setReturnType(returnType);
        }
    }
     FunctionInfo* getFunctionInfo() const { return this->funcInfo; }
    
    void setFunctionDefined(bool defined) {
        if (funcInfo != nullptr) {
            funcInfo->setIsDefined(defined);
        }
    }
    
    void setFunctionDeclared(bool declared) {
        if (funcInfo != nullptr) {
            funcInfo->setIsDeclared(declared);
        }
    }
    
    bool isFunctionDefined() const {
        return (funcInfo != nullptr) ? funcInfo->getIsDefined() : false;
    }
    
    bool isFunctionDeclared() const {
        return (funcInfo != nullptr) ? funcInfo->getIsDeclared() : false;
    }
    
    void addFunctionParameter(string type, string name) {
        if (funcInfo != nullptr) {
            funcInfo->addParameter(type, name);
        }
    }
    
    int getFunctionParameterCount() const {
        return (funcInfo != nullptr) ? funcInfo->getParameterCount() : 0;
    }
    
    string getFunctionReturnType() const {
        return (funcInfo != nullptr) ? funcInfo->getReturnType() : "";
    }
    
    string getFunctionParameterType(int index) const {
        return (funcInfo != nullptr) ? funcInfo->getParameterType(index) : "";
    }
    
    // Helper method to check if two function signatures match
    int matchesFunctionSignature(const SymbolInfo* other) const {
        if (!this->isFunction || !other->isFunction || 
            this->funcInfo == nullptr || other->funcInfo == nullptr) {
            return 0;
        }
        
        // Check return type
        if (this->extrainfo->getReturnType() != other->extrainfo->getReturnType()) {
            return 1;
        }
        
        // Check parameter count
        if (this->funcInfo->getParameterCount() != other->funcInfo->getParameterCount()) {
            return 2;
        }
        
        // Check parameter types
        for (int i = 0; i < this->funcInfo->getParameterCount(); i++) {
            if (this->funcInfo->getParameterType(i) != other->funcInfo->getParameterType(i)) {
                return 3;
            }
        }
        
        return -1;
    }

    // Function to print all available information from a SymbolInfo object
void printSymbolInfo(const SymbolInfo* symbol) {
    if (symbol == nullptr) {
        cout << "Symbol is null" << endl;
        return;
    }
    
    cout << "=== Symbol Information ===" << endl;
    cout << "Symbol Name: " << symbol->getsymbolName() << endl;
    cout << "Symbol Type: " << symbol->getSymbolType() << endl;
    cout << "Data Type: " << symbol->getDataType() << endl;
    
    // Array information
    if (symbol->getIsArray()) {
        cout << "Is Array: Yes" << endl;
        cout << "Array Size: " << symbol->getArraySize() << endl;
    } else {
        cout << "Is Array: No" << endl;
    }
    
    // Function information
    if (symbol->getIsFunction()) {
        cout << "Is Function: Yes" << endl;
        cout << "Function Defined: " << (symbol->isFunctionDefined() ? "Yes" : "No") << endl;
        cout << "Function Declared: " << (symbol->isFunctionDeclared() ? "Yes" : "No") << endl;
        cout << "Return Type: " << symbol->getFunctionReturnType() << endl;
        cout << "Parameter Count: " << symbol->getFunctionParameterCount() << endl;
        
        // Print function parameters
        if (symbol->getFunctionParameterCount() > 0) {
            cout << "Parameters:" << endl;
            for (int i = 0; i < symbol->getFunctionParameterCount(); i++) {
                cout << "  [" << i << "] Type: " << symbol->getFunctionParameterType(i) 
                     << ", Name: " << symbol->getFunctionInfo()->getParameterName(i) << endl;
            }
        }
    } else {
        cout << "Is Function: No" << endl;
    }
    
    // Extra symbol information (if available)
    if (symbol->getExtraSymbolInfo() != nullptr) {
        cout << "Extra Info Available: Yes" << endl;
        cout << "Extra Return Type: " << symbol->getReturnType() << endl;
        cout << "Extra Parameter Count: " << symbol->getNumberOfParameters() << endl;
        
        // Print extra parameters if available
        vector<param> params = symbol->getParameterList();
        if (!params.empty()) {
            cout << "Extra Parameters:" << endl;
            for (size_t i = 0; i < params.size(); i++) {
                cout << "  [" << i << "] " << params[i].getParameterName() << " : " << params[i].getParameterType()<< endl;
            }
        }
    } else {
        cout << "Extra Info Available: No" << endl;
    }
    
    // Next symbol in chain
    if (symbol->getnextSymbol() != nullptr) {
        cout << "Has Next Symbol: Yes" << endl;
    } else {
        cout << "Has Next Symbol: No" << endl;
    }
    
    cout << "=========================" << endl << endl;
}

};

#endif