
#include <iostream>
#include <sstream>
#include <string>

#include "2105123_SymbolTable.hpp"
using namespace std;

#define MAX_ARGS 1000

int main(int argc, char *argv[])
{
  if (argc < 3)
  {
    cerr << "Usage: " << argv[0] << " <input_file> <output_file> [hash_function]#Hash Function is optional" << endl;
    cerr << "Example: " << argv[0] << " input.txt output.txt sdbm" << endl;
    return 1;
  }

  string funcName = argc > 3 ? argv[3] : "sdbm";
  HashFunction hashFn = nullptr;

  if (funcName == "sdbm")
    hashFn = &Hash::SDBMHash;
  else if (funcName == "djb")
    hashFn = &Hash::DJB2Hash;
  else if (funcName == "additive")
    hashFn = &Hash::AdditiveHash;
  else if (funcName == "fnv")
    hashFn = &Hash::FNV1aHash;
  else
  {
    cout << "Invalid hash function name. Use: sdbm, djb,  additive or fnv."
         << endl;
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

  int bucketSize;
  cin >> bucketSize;
  cin.ignore();
  int cmdCnt = 0;

  SymbolTable *symbolTable = new SymbolTable(bucketSize, hashFn);

  string line;
  while (getline(cin, line))
  {
    if (line.empty())
      continue;
    stringstream ss(line);
    string command;
    ss >> command;

    cout << "Cmd " << (++cmdCnt) << ": " << line << endl;

    if (command == "I")

    {
      string name, type;
      if (!(ss >> name >> type))
      {
        cout << "\tNumber of parameters mismatch for the command I" << endl;
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
            type = type + ",";
            type += args[0];
            if (argCount > 1)
            {
              type += "<==(";
              for (int i = 1; i < argCount - 1; i++)
              {
                if (i == 1)
                  type += ("" + args[i]);
                else
                  type += ("," + args[i]);
              }
              type += ("," + args[argCount - 1] + ")");
            }
            // symbolTable->Insert(name, type);
          }
          else if (type == "STRUCT" || type == "UNION")
          {
            if (argCount % 2 == 0)
            {
              type += ",{";
              int i = 0;
              while (i < argCount - 2)
              {
                type += ("(" + args[i] + "," + args[i + 1] + "),");
                i += 2;
              }
              type +=
                  ("(" + args[argCount - 2] + "," + args[argCount - 1] + ")}");
            }
            else
            {
              cout << "\t For every arguement of STRUCT or UNION there should "
                      "be a pair "
                   << endl;
            }
          }
        }

        if (symbolTable->Insert(name, type))
        {
          cout << "\tInserted in ScopeTable# "
               << symbolTable->getCurrrentScopeTable()->getUnique_number()
               << " at position "
               << symbolTable->getCurrrentScopeTable()->getPositionIndex()
               << ", " << symbolTable->getCurrrentScopeTable()->getChainIndex()
               << endl;
        }
        else
        {
          cout << "\t'" << name << "' already exists in the current ScopeTable"
               << endl;
        }
      }
    }
    else if (command == "L")
    {
      string name, type, extra;

      if ((ss >> name >> type))
      {
        cout << "\tNumber of parameters mismatch for the command L" << endl;
      }
      else
      {
        SymbolInfo *res = symbolTable->LookUp(name);
        if (res == nullptr)
        {
          cout << "\t'" << name << "' not found in any of the ScopeTables"
               << endl;
        }
        else
        {
          cout << "\t'" << name << "' found in ScopeTable# "
               << symbolTable->getLookupScopeTable()->getUnique_number()
               << " at position "
               << symbolTable->getLookupScopeTable()->getPositionIndex() << ", "
               << symbolTable->getLookupScopeTable()->getChainIndex() << endl;
        }
      }
    }
    else if (command == "D")
    {
      string name, extra;
      if (!(ss >> name) || (ss >> extra))
      {
        cout << "\tNumber of parameters mismatch for the command D" << endl;
      }
      else
      {
        if (symbolTable->getCurrrentScopeTable() == nullptr)
        {
          cout << "\tNo scope table exists" << endl;
        }
        else
        {
          if (symbolTable->Remove(name))
          {
            cout << "\tDeleted '" << name << "' from ScopeTable# "
                 << symbolTable->getCurrrentScopeTable()->getUnique_number()
                 << " at position "
                 << symbolTable->getCurrrentScopeTable()->getPositionIndex()
                 << ", "
                 << symbolTable->getCurrrentScopeTable()->getChainIndex()
                 << endl;
          }
          else
          {
            cout << "\tNot found in the current ScopeTable" << endl;
          }
        }
      }
    }
    else if (command == "P")
    {
      string param, extra;
      if (!(ss >> param) || (ss >> extra))
      {
        cout << "\tNumber of parameters mismatch for the command P" << endl;
      }
      else if (param == "A")
      {
        if (symbolTable->getCurrrentScopeTable() == nullptr)
        {
          cout << "\tNo scope table exists" << endl;
        }
        else
          symbolTable->PrintAllScopeTable();
      }
      else if (param == "C")
      {
        if (symbolTable->getCurrrentScopeTable() == nullptr)
        {
          cout << "\tNo scope table exists" << endl;
        }
        else
          symbolTable->PrintCurrentScopeTable();
      }
      else
        cout << "\tInvalid parameter for command P" << endl;
    }
    else if (command == "S")
    {
      string extra;
      if (ss >> extra)
      {
        cout << "\tNumber of parameters mismatch for the command S" << endl;
      }
      else
      {
        symbolTable->EnterScope();
        // cout << "\tScopeTable# " << symbolTable->getCurrrentScopeTable()->getUnique_number() << " created" << endl;
      }
    }
    else if (command == "E")
    {
      string extra;
      if (ss >> extra)
      {
        cout << "\tNumber of parameters mismatch for the command E" << endl;
      }
      else
      {
        if (symbolTable->getCurrrentScopeTable() == nullptr)
        {
          cout << "\tNo scope table exists" << endl;
        }
        else
        {
          symbolTable->ExitScope();
        }
      }
    }
    else if (command == "Q")
    {
      string extra;
      if (ss >> extra)
      {
        cout << "\tNumber of parameters mismatch for the command Q" << endl;
      }
      else
      {
        delete symbolTable;
        break;
      }
    }
    else
    {
      cout << "\tInvalid command" << endl;
    }

    cout << endl;
  }

  fclose(stdin);
  fclose(stdout);
  cout << "Output written to 'output.txt'" << endl;
  return 0;
}
