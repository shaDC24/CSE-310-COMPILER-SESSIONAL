#ifndef SCOPETABLE_HEADER
#define SCOPETABLE_HEADER

#include <iostream>
#include <string>
#include <ostream>
#include "2105123_HashFunction.hpp"
#include "2105123_SymbolInfo.hpp"

using namespace std;

class ScopeTable
{
private:
  int num_buckets;
  SymbolInfo **buckets;
  ScopeTable *parent_scope;
  int unique_number;

  // extra
  HashFunction hashFn;
  int collisionCount;
  int chainIndex;
  int positionIndex;
  //offline-3
  int childCount;
  string scopeID;
  //icg
  int global_st_offset;


  unsigned int hashFunction(string symbolName)
  {
   // cout<<num_buckets<<endl;
    unsigned int hashValue = (hashFn(symbolName, num_buckets));
    //cout<<hashValue<<endl;
    return (hashValue)%num_buckets;
  }
  int position(int hashValue) { return (hashValue); }

public:
  bool Insert(string symbolName, string symbolType)
  {
    SymbolInfo *symbol = new SymbolInfo(symbolName, symbolType);
    unsigned int hashValue = hashFunction(symbolName);
    
    SymbolInfo *current = buckets[hashValue];
    int localChainIndex = 0;
    if (current == nullptr)
    {
      buckets[hashValue] = symbol;
      setPositionIndex(hashValue);
      setChainIndex(localChainIndex);
     // cout<<symbolName<<":"<<hashValue<<":"<<localChainIndex<<endl;
      return true;
    }

    SymbolInfo *prev = nullptr;
    while (current != nullptr)
    {
      if (current->getsymbolName() == symbolName)
      {
        setPositionIndex(hashValue);
        setChainIndex(localChainIndex);
        delete symbol;
        return false;
      }
      prev = current;
      current = current->getnextSymbol();
      localChainIndex++;
    }
    // Task-B
    collisionCount++;
    // cout << "Collision count ; " << this->collisionCount << endl;

    prev->setnextSymbol(symbol);
    setPositionIndex(position(hashValue));
    setChainIndex(localChainIndex);
    //cout<<symbolName<<":"<<hashValue<<":"<<localChainIndex<<endl;
    return true;
  }
    bool Insert(string symbolName, string symbolType,string rettype,int size)
  {
    SymbolInfo *symbol = new SymbolInfo(symbolName, symbolType,rettype,size);
    unsigned int hashValue = hashFunction(symbolName);
    
    SymbolInfo *current = buckets[hashValue];
    int localChainIndex = 0;
    if (current == nullptr)
    {
      buckets[hashValue] = symbol;
      setPositionIndex(hashValue);
      setChainIndex(localChainIndex);
     // cout<<symbolName<<":"<<hashValue<<":"<<localChainIndex<<endl;
      return true;
    }

    SymbolInfo *prev = nullptr;
    while (current != nullptr)
    {
      if (current->getsymbolName() == symbolName)
      {
        setPositionIndex(hashValue);
        setChainIndex(localChainIndex);
        delete symbol;
        return false;
      }
      prev = current;
      current = current->getnextSymbol();
      localChainIndex++;
    }
    // Task-B
    collisionCount++;
    // cout << "Collision count ; " << this->collisionCount << endl;

    prev->setnextSymbol(symbol);
    setPositionIndex(position(hashValue));
    setChainIndex(localChainIndex);
    //cout<<symbolName<<":"<<hashValue<<":"<<localChainIndex<<endl;
    return true;
  }
  bool Insert(SymbolInfo* symbol) {
    if (symbol == nullptr) return false;

    unsigned int hashValue = hashFunction(symbol->getsymbolName());
    SymbolInfo* current = buckets[hashValue];
    int localChainIndex = 0;

    if (current == nullptr) {
        buckets[hashValue] = symbol;
        setPositionIndex(hashValue);
        setChainIndex(localChainIndex);
        return true;
    }

    SymbolInfo* prev = nullptr;
    while (current != nullptr) {
        if (current->getsymbolName() == symbol->getsymbolName()) {
            setPositionIndex(hashValue);
            setChainIndex(localChainIndex);
            return false;
        }
        prev = current;
        current = current->getnextSymbol();
        localChainIndex++;
    }

    collisionCount++;
    prev->setnextSymbol(symbol);
    setPositionIndex(position(hashValue));
    setChainIndex(localChainIndex);
    return true;
}
SymbolInfo *LookUp(string symbolName, string symboltype)
{
    unsigned int hashValue = hashFunction(symbolName);
    SymbolInfo *iteratorSymbol = buckets[hashValue];
    int localchainIndex = 1;
    while (iteratorSymbol != nullptr)
    {
        string itrSymbolName = iteratorSymbol->getsymbolName();
        string itrReturnType = iteratorSymbol->getReturnType();
        
        if (itrSymbolName == symbolName && itrReturnType == symboltype)
        {
            setPositionIndex(position(hashValue));
            setChainIndex(localchainIndex);
            return iteratorSymbol;
        }
        iteratorSymbol = iteratorSymbol->getnextSymbol();
        localchainIndex++;
    }
    return nullptr;
}

  SymbolInfo *LookUp2(string symbolName)
  {
    unsigned int hashValue = hashFunction(symbolName);
    
    SymbolInfo *iteratorSymbol = buckets[hashValue];
    int localchainIndex = 1;
    while (iteratorSymbol != nullptr)
    {
      string itrSymbolName = iteratorSymbol->getsymbolName();
      if (itrSymbolName == symbolName)
      {
        setPositionIndex(position(hashValue));
        setChainIndex(localchainIndex);
        return iteratorSymbol;
      }
      iteratorSymbol = iteratorSymbol->getnextSymbol();
      localchainIndex++;
    }
    return nullptr;
  }

  bool Delete(string symbolName)
  {
    unsigned int hashValue = hashFunction(symbolName);
    SymbolInfo *currSymbol = buckets[hashValue];
    SymbolInfo *prevSymbol = nullptr;
    int localchainIndex = 1;

    while (currSymbol != nullptr)
    {
      if (currSymbol->getsymbolName() == symbolName)
      {
        if (prevSymbol == nullptr)
        {
          buckets[hashValue] = currSymbol->getnextSymbol();
        }
        else
        {
          prevSymbol->setnextSymbol(currSymbol->getnextSymbol());
        }

        delete currSymbol;
        setPositionIndex(position(hashValue));
        setChainIndex(localchainIndex);
        return true;
      }

      prevSymbol = currSymbol;
      currSymbol = currSymbol->getnextSymbol();
      localchainIndex++;
    }
    return false;
  }

  void Print()
  {
    cout << "\tScopeTable# " << unique_number << endl;
    SymbolInfo *tmp;
    for (int i = 1; i <num_buckets; i++)
    {
      cout << "\t" << (i+1) << "-->";
      tmp = buckets[i];
      while (tmp != nullptr)
      {
        cout << " <" << tmp->getsymbolName() << "," << tmp->getSymbolType()
             << ">" << " ";
        tmp = tmp->getnextSymbol();
      }
      cout << endl;
    }
  }

  void Print(int level)
  {
    string indent(level + 1, '\t');
    cout << indent << "ScopeTable# " << unique_number << endl;
    SymbolInfo *tmp;
    for (int i = 0; i < num_buckets; i++)
    {
      cout << indent << (i + 1) << "--> ";
      tmp = buckets[i];
      while (tmp != nullptr)
      {
        cout << "<" << tmp->getsymbolName() << "," << tmp->getSymbolType()
             << ">" << " ";
        tmp = tmp->getnextSymbol();
      }
      cout << endl;
    }
  }
  const char* getTable() const {
    static string full_id;  // Keeps the string alive after return

    if (parent_scope == nullptr) {
        full_id = "1";
    } else {
        
        full_id = parent_scope->getTable();
        //cout<<"...........parent........."<<full_id<<"............................"<<endl;
        full_id += "." + to_string(1);
        //cout<<"...........child........."<<full_id<<"............................"<<endl;
    }

    return full_id.c_str();
}
  void setScopeID(string id) {
      scopeID = id;
  }
  string getScopeID() const {
      return scopeID;
  }


  void Print(FILE* logout, int level) 
  {

      fprintf(logout, "ScopeTable # %s\n", getTable());


      
      SymbolInfo *tmp;
      for (int i = 0; i <num_buckets; i++) 
      {
        tmp = buckets[i];
        if(tmp==nullptr)
         continue;
        fprintf(logout, "%d --> ",  (i));
          
          
        while (tmp != nullptr) 
          {
              fprintf(logout, "< %s : %s >", 
                     tmp->getsymbolName().c_str(), 
                     tmp->getSymbolType().c_str());
              tmp = tmp->getnextSymbol();
          }
          fprintf(logout, "\n");
      }
  }

  void incrementChildCount() { childCount++; }
  int getChildCount() const { return childCount; }
  void Print(ostream& logout, int level) {
      logout<<"ScopeTable # "<<getScopeID()<<endl;


      for (int i = 0; i < num_buckets; i++) {
          SymbolInfo* tmp = buckets[i];
          if (tmp == nullptr)
              continue;

          logout << i << " --> ";
          while (tmp != nullptr) {
              logout << "< " << tmp->getsymbolName() << " : " << tmp->getSymbolType() << " >";
              //tmp->printSymbolInfo(tmp);
              tmp = tmp->getnextSymbol();
          }
          logout << endl;
      }
      
  }

  ScopeTable(int numBuckets)
  {
    this->num_buckets = numBuckets;
    buckets = new SymbolInfo *[this->num_buckets+1]();
    for (int i = 0; i < num_buckets; i++)
    {
      buckets[i] = nullptr;
    }
    this->childCount=0;
    // Task B
    this->collisionCount = 0;
    this->global_st_offset=0;
  }

  ~ScopeTable()
  {
    for (int i = 0; i < num_buckets; i++)
    {
      SymbolInfo *curSymbol = buckets[i];

      while (curSymbol != nullptr)
      {
        SymbolInfo *nextSymbol = curSymbol->getnextSymbol();
        delete curSymbol;
        curSymbol = nextSymbol;
      }
    }
    delete[] buckets;
    parent_scope = nullptr;
  }

  // extra
  void setParentScopeTable(ScopeTable *parentscope)
  {
    this->parent_scope = parentscope;
  }
  ScopeTable *getParentScope() { return this->parent_scope; }
  void setUnique_number(int numberOfId) { this->unique_number = numberOfId; }
  int getUnique_number() { return this->unique_number; }
  void setHashFunction(HashFunction hashFn) { this->hashFn = hashFn; }
  void setChainIndex(int index) { this->chainIndex = index; }
  int getChainIndex() { return this->chainIndex; }
  void setPositionIndex(int index) { this->positionIndex = index; }
  int getPositionIndex() { return this->positionIndex; }
  int getBucketSize() { return this->num_buckets; }

  // Task B
  int getCollisionCount() const { return collisionCount; }
  //offline4
  void set_global_st_offset(int s)
  {
      this->global_st_offset=s;
  }
  int get_global_st_offset()
  {
    return this->global_st_offset;
  }

};

#endif