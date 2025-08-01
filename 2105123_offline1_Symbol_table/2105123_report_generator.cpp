
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>

#include "2105123_SymbolTable.hpp"
using namespace std;

#define MAX_ARGS 1000

class ReportRowContent
{
public:
  string funcName;
  int totalScopeTables;
  double meanRatio;
  int totalScopeNumber;
  SymbolTable *symbolTable;

  void printCollisionRecord()
  {
    if (symbolTable)
    {
      cout << "Collision Report for Hash Function: " << funcName << "\n";
      cout << string(65, '-') << "\n";
      symbolTable->printCollisionRecords();
      cout << "\n";
    }
  }
};

ReportRowContent TaskB_ReportGeneration(HashFunction hashFn, const char *funcName, const string &inputContent)
{
  stringstream input(inputContent);

  int bucketSize;
  input >> bucketSize;
  input.ignore();
  SymbolTable *symbolTable = new SymbolTable(bucketSize, hashFn, false);

  string line;
  while (getline(input, line))
  {
    if (line.empty())
      continue;
    stringstream ss(line);
    string command;
    ss >> command;

    if (command == "I")
    {
      string strname, type;
      if (!(ss >> strname >> type))
      {
        continue;
      }
      else
      {
        string extraToken;
        string args[MAX_ARGS];
        int argCount = 0;

        while (ss >> extraToken && argCount < MAX_ARGS)
        {
          args[argCount++] = extraToken;
        }

        if (argCount > 0)
        {
          if (type == "FUNCTION")
          {
            type = type + "," + args[0];
            if (argCount > 1)
            {
              type += "<==(";
              for (int i = 1; i < argCount; i++)
              {
                if (i > 1)
                  type += ",";
                type += args[i];
              }
              type += ")";
            }
          }
          else if (type == "STRUCT" || type == "UNION")
          {
            if (argCount % 2 == 0)
            {
              type += ",{";
              for (int i = 0; i < argCount; i += 2)
              {
                if (i > 0)
                  type += ",";
                type += "(" + args[i] + "," + args[i + 1] + ")";
              }
              type += "}";
            }
          }
        }
        symbolTable->Insert(strname, type);
      }
    }
    else if (command == "L")
    {
      string strname;
      ss >> strname;
      symbolTable->LookUp(strname);
    }
    else if (command == "D")
    {
      string strname;
      ss >> strname;
      symbolTable->Remove(strname);
    }
    else if (command == "P")
    {
      string strParameter;
      ss >> strParameter;
      if (strParameter == "A")
      {
        // symbolTable->PrintAllScopeTable();
      }
      else if (strParameter == "C")
      {
        // symbolTable->PrintCurrentScopeTable();
      }
    }
    else if (command == "S")
    {
      symbolTable->EnterScope();
    }
    else if (command == "E")
    {
      symbolTable->ExitScope();
    }
    else if (command == "Q")
    {
      break;
    }
    else
    {
    }
  }

  double meanRatio = symbolTable->getMeanRatio();
  int totalScopeTables = symbolTable->getTotalScopeTable();
  int totalScNum = symbolTable->getTotalScopeTable();

  ReportRowContent row = {funcName, totalScopeTables, meanRatio, totalScNum,
                          symbolTable};
  return row;
}

int main(int argc, char *argv[])
{
  if (argc < 3)
  {
    cerr << "Usage: " << argv[0] << " <input_file> <output_file> [hash_function]#Hash Function is optional" << endl;
    cerr << "Example: " << argv[0] << " input.txt output.txt sdbm" << endl;
    return 1;
  }
  string inputFile = argv[1];
  string outputFile = argv[2];

  FILE *inFile = freopen(inputFile.c_str(), "r", stdin);
  if (inFile == nullptr)
  {
    cerr << "Error: Cannot open input file '" << inputFile << "'." << endl;
    return 1;
  }

  FILE *outFile = freopen(outputFile.c_str(), "w", stdout);
  if (outFile == nullptr)
  {
    cerr << "Error: Cannot open output file '" << outputFile << "'." << endl;
    return 1;
  }

  stringstream buffer;
  string line;
  while (getline(cin, line))
  {
    buffer << line << '\n';
  }
  string inputContent = buffer.str();

  // All supported functions
  const char *functionNames[4] = {"sdbm", "djb", "additive", "fnv"};
  HashFunction functionPointers[4] = {
      &Hash::SDBMHash,
      &Hash::DJB2Hash,
      &Hash::AdditiveHash,
      &Hash::FNV1aHash};

  // If a specific function is given, run only that
  if (argc >= 4)
  {
    string selected = argv[3];
    bool found = false;

    for (int i = 0; i < 4; i++)
    {
      if (selected == functionNames[i])
      {
        ReportRowContent row = TaskB_ReportGeneration(functionPointers[i], functionNames[i], inputContent);

        cout << left << setw(20) << "Hash Function"
             << setw(25) << "Total ScopeTables"
             << setw(20) << "Mean Collision Ratio" << endl;
        cout << string(65, '-') << endl;

        cout << left << setw(20) << row.funcName
             << setw(25) << row.totalScopeTables
             << setw(20) << fixed << setprecision(6) << row.meanRatio << endl;

        cout << "\n\n=== Detailed Collision Records ===\n\n";
        row.printCollisionRecord();

        delete row.symbolTable;
        found = true;
        break;
      }
    }

    if (!found)
    {
      cout << "Invalid hash function name. Use: sdbm, djb, additive, or fnv." << endl;
    }
  }
  else
  {
    // Generate all
    ReportRowContent report[4];
    for (int i = 0; i < 4; i++)
    {
      report[i] = TaskB_ReportGeneration(functionPointers[i], functionNames[i], inputContent);
    }

    cout << left << setw(20) << "Hash Function"
         << setw(25) << "Total ScopeTables"
         << setw(20) << "Mean Collision Ratio" << endl;
    cout << string(65, '-') << endl;

    for (const auto &row : report)
    {
      cout << left << setw(20) << row.funcName
           << setw(25) << row.totalScopeTables
           << setw(20) << fixed << setprecision(6) << row.meanRatio << endl;
    }

    cout << "\n\n=== Detailed Collision Records ===\n\n";
    for (int i = 0; i < 4; i++)
    {
      report[i].printCollisionRecord();
    }

    for (auto &row : report)
    {
      delete row.symbolTable;
    }
  }

  fclose(stdin);
  fclose(stdout);
  return 0;
}

