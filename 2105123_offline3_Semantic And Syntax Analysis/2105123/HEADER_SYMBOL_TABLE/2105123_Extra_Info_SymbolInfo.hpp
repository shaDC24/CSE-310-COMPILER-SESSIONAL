#ifndef EXTRA_INFO_SYMBOL_INFO_HEADER
#define EXTRA_INFO_SYMBOL_INFO_HEADER

#include <iostream>
#include <string>
#include <vector>
using namespace std;

class param {
private:
    string parameter_name;
    string parameter_type;

public:
    param() {
        parameter_name = "";
        parameter_type = "";
    }

    param( string& name,  string& type) {
        parameter_name = name;
        parameter_type = type;
    }

    // param( param& other) {
    //     parameter_name = other.parameter_name;
    //     parameter_type = other.parameter_type;
    // }

    // param& operator=( param& other) {
    //     if (this != &other) {
    //         parameter_name = other.parameter_name;
    //         parameter_type = other.parameter_type;
    //     }
    //     return *this;
    // }


    void setParameterName( string& name) {
        parameter_name = name;
    }

    void setParameterType( string& type) {
        parameter_type = type;
    }

    string getParameterName()  {
        return parameter_name;
    }

    string getParameterType()  {
        return parameter_type;
    }
};

class ExtraSymbolInfo {
private:
    string return_type;
    int number_of_parameters;
    vector<param> parameter_list; 

public:

    ExtraSymbolInfo() {
        return_type = "";
        number_of_parameters = 0;
    }

  
    // ExtraSymbolInfo(string& retType, int numParams, param* params) {
    //     return_type = retType;
    //     number_of_parameters = numParams;
    //     if (numParams > 0 && params != nullptr) {
    //         parameter_list.resize(numParams);
    //         for (int i = 0; i < numParams; ++i) {
    //             parameter_list[i] = params[i];
    //         }
    //     }
    // }
    ExtraSymbolInfo(string& retType, int numParams) {
        return_type = retType;
        number_of_parameters = numParams;
        // if (numParams > 0) {
        //     parameter_list.resize(numParams);
        // }
    }

    ExtraSymbolInfo(ExtraSymbolInfo& other) {
        return_type = other.return_type;
        number_of_parameters = other.number_of_parameters;
        parameter_list = other.parameter_list;
    }


    ExtraSymbolInfo& operator=(const ExtraSymbolInfo& other) {
        if (this != &other) {
            return_type = other.return_type;
            number_of_parameters = other.number_of_parameters;
            parameter_list = other.parameter_list;
        }
        return *this;
    }


    ~ExtraSymbolInfo() {
    }

 
    void setReturnType(string& type) { return_type = type; }
    void setNumberOfParameters(int num) { 
        number_of_parameters = num; 
       // parameter_list.resize(num);
    }
    // void setParameterList(param* params, int numParams) {
    //     number_of_parameters = numParams;
    //     if (numParams > 0 && params != nullptr) {
    //         parameter_list.resize(numParams);
    //         for (int i = 0; i < numParams; ++i) {
    //             parameter_list[i] = params[i];
    //         }
    //     } else {
    //         parameter_list.clear();
    //     }
    // }
void addParameter(param& newParam) {
    parameter_list.push_back(newParam);
  //  ++number_of_parameters;
}
void addPara(string name,string type)
{
    parameter_list.push_back(param(name,type));
}

void removeParameter(int index) {
        if (index < 0 || index >= number_of_parameters) {
            cerr << "Invalid index to remove parameter!" << endl;
            return;
        }

        parameter_list.erase(parameter_list.begin() + index);
       // --number_of_parameters;
}


    string getReturnType() { return return_type; }
    int getNumberOfParameters()  { return parameter_list.size(); }
    vector<param> getParameterList() { 
        if (parameter_list.empty()) return {};
        return parameter_list;
    }

  
};

#endif