#ifndef SYMBOLTABLE_HEADER
#define SYMBOLTABLE_HEADER

#include <iostream>
#include <string>
#include <fstream>
#include <ostream>

#include "2105123_ScopeTable.hpp"

using namespace std;

// Task B
class CollisionNodes
{
public:
  int tableId;
  int collision;
  int bucketSize;
};

class SymbolTable
{
private:
  ScopeTable *curScopeTable;
  int total_num_buckets;

  // extra
  ScopeTable *LookUpScopeTable;
  int scopeUniqueNumber;
  HashFunction hashFn;

  // Task B

  CollisionNodes *collisionRecord;
  int MaxsizeOfScopeTable;
  int currentScopeTableSize;
  bool isPrint;
  string sc_id;


  void updateCollisionRecord(int tableId, int collision, int bucketSize)
  {
    if (tableId >= 0 && (tableId) < MaxsizeOfScopeTable)
    {
      collisionRecord[tableId].tableId = tableId;
      collisionRecord[tableId].collision = collision;
      collisionRecord[tableId].bucketSize = bucketSize;
    }
  }

public:
  void EnterScope()
  {
    ScopeTable *newScopeTable = new ScopeTable(total_num_buckets);
    newScopeTable->setParentScopeTable(curScopeTable);
    newScopeTable->setHashFunction(this->hashFn);
    newScopeTable->setUnique_number(++this->scopeUniqueNumber);
   
    newScopeTable->setScopeID(scopefunc());
    curScopeTable = newScopeTable;
    if (isPrint)
       cout<< "\tScopeTable# " << this->scopeUniqueNumber << " created" << endl;
  }

  void ExitScope()
  { 
    if (this->getCurrrentScopeTable() == nullptr)
    {
      if(isPrint)
      cout << "\tNo scope table exists" << endl;
      return ;
    }
    ScopeTable *tmpSymbol = curScopeTable;
    curScopeTable = curScopeTable->getParentScope();
    if (isPrint)
       cout<< "\tScopeTable# " << tmpSymbol->getUnique_number() << " removed"
          << endl;
    delete tmpSymbol;
    return;
  }
  bool Insert(SymbolInfo* symbol) {
    if (curScopeTable == nullptr) {
        EnterScope();
    }

    bool res = curScopeTable->Insert(symbol);
    updateCollisionRecord(
        curScopeTable->getUnique_number() - 1,
        curScopeTable->getCollisionCount(),
        curScopeTable->getBucketSize());

    return res;
}

  bool Insert(string symbolName, string symbolType)
  {
    if (curScopeTable == nullptr)
    {
      EnterScope();
    }
    bool res = curScopeTable->Insert(symbolName, symbolType);
    // Task B
    updateCollisionRecord(curScopeTable->getUnique_number() - 1,
                          curScopeTable->getCollisionCount(),
                          curScopeTable->getBucketSize());

    if (res)
    {
      return true;
    }
    else
    {
      return false;
    }
  }

  bool Remove(string symbolName) { 
    if (this->getCurrrentScopeTable() == nullptr)
    {
      if(isPrint)
      cout << "\tNo scope table exists" << endl;
      return false;
    }
    return curScopeTable->Delete(symbolName); }

  SymbolInfo *LookUp2(string symbolName)
  {
    if (this->getCurrrentScopeTable() == nullptr)
    {
      if(isPrint)
      cout << "\tNo scope table exists" << endl;
      return nullptr;
    }
    ScopeTable *tmpTable = curScopeTable;
   while (tmpTable != nullptr)
    {
      SymbolInfo *symbol = tmpTable->LookUp2(symbolName);
      //cout<<symbolName<<endl;
      if (symbol != nullptr)
      {
        this->LookUpScopeTable = tmpTable;
        return symbol;
      }
      //cout<<"ok"<<endl;
     tmpTable = tmpTable->getParentScope();
    }
    return nullptr;
  }
    SymbolInfo *LookUp(string symbolName,string type)
  {
    if (this->getCurrrentScopeTable() == nullptr)
    {
      if(isPrint)
      cout << "\tNo scope table exists" << endl;
      return nullptr;
    }
    ScopeTable *tmpTable = curScopeTable;
    while (tmpTable != nullptr)
    {
      SymbolInfo *symbol = tmpTable->LookUp(symbolName,type);
      //cout<<symbolName<<endl;
      if (symbol != nullptr)
      {
        this->LookUpScopeTable = tmpTable;
        return symbol;
      }
     // cout<<"ok"<<endl;
      tmpTable = tmpTable->getParentScope();
    }
    return nullptr;
  }

 SymbolInfo *LookUp3(string symbolName)
  {
    if (this->getCurrrentScopeTable() == nullptr)
    {
      if(isPrint)
      cout << "\tNo scope table exists" << endl;
      return nullptr;
    }
    ScopeTable *tmpTable = curScopeTable;
   //while (tmpTable != nullptr)
    {
      SymbolInfo *symbol = tmpTable->LookUp2(symbolName);
      //cout<<symbolName<<endl;
      if (symbol != nullptr)
      {
        this->LookUpScopeTable = tmpTable;
        return symbol;
      }
     // cout<<"ok"<<endl;
     //tmpTable = tmpTable->getParentScope();
    }
    return nullptr;
  }

  void PrintCurrentScopeTable() { 
    if (this->getCurrrentScopeTable() == nullptr)
    {
      if(isPrint)
      cout << "\tNo scope table exists" << endl;
      return;
    }
    curScopeTable->Print(); 
  }

  void PrintAllScopeTable()
  {
    if (this->getCurrrentScopeTable() == nullptr)
    {
      if(isPrint)
      cout << "\tNo scope table exists" << endl;
      return;
    }
   
    ScopeTable *tmpTable = curScopeTable;
    int level = 0;

    while (tmpTable != nullptr)
    {
      tmpTable->Print(level);
      tmpTable = tmpTable->getParentScope();
      cout << endl;
      level++;
    }
  }
  void PrintAllScopeTable(FILE* logout)  
  {
      if (this->getCurrrentScopeTable() == nullptr)
      {
          if (isPrint)
              fprintf(logout, "\tNo scope table exists\n");  
          return;
      }
  
      ScopeTable *tmpTable = curScopeTable;
      int level = 0;
  
      while (tmpTable != nullptr)
      {
          tmpTable->Print(logout, level);  
          tmpTable = tmpTable->getParentScope();
          level++;
      }
      fprintf(logout, "\n"); 

  }



  string scopefunc()
  {
  string newID;

  if (curScopeTable == nullptr) {
      newID = "1";
  } else {
      string parentID = curScopeTable->getScopeID();
      int siblingNumber = curScopeTable->getChildCount() + 1;
      curScopeTable->incrementChildCount(); 
      newID = parentID + "." + to_string(siblingNumber);
  }
   return newID;

  }

  void PrintAllScopeTable(ostream& logout) {
      if (this->getCurrrentScopeTable() == nullptr) {
          if (isPrint)
              logout << "\tNo scope table exists\n";
          return;
      }
      
      ScopeTable* tmpTable = curScopeTable;
      int level = 0;
      
      while (tmpTable != nullptr) {
          tmpTable->Print(logout, level);  
          tmpTable = tmpTable->getParentScope();
          level++;
      }

      logout << endl;
  }

  


  // extra

  SymbolTable(int total_num_buckets, HashFunction hashFn, bool isPrint = false)
  {
    this->total_num_buckets = total_num_buckets;
    this->curScopeTable = nullptr;
    this->LookUpScopeTable = nullptr;
    //this->globalScopeUniqueNumber=0;
    this->scopeUniqueNumber = 0;
    this->hashFn = hashFn;

    // Task B
    this->isPrint = isPrint;
    this->MaxsizeOfScopeTable = 100;
    this->collisionRecord = new CollisionNodes[MaxsizeOfScopeTable];
    this->currentScopeTableSize = 0;
    for (int i = 0; i < MaxsizeOfScopeTable; ++i)
    {
      collisionRecord[i].tableId = -1;
      collisionRecord[i].collision = 0;
      collisionRecord[i].bucketSize = 0;
    }
    EnterScope();
  }
  ~SymbolTable()
  {
    while (curScopeTable != nullptr)
    {
      ExitScope();
    }
    curScopeTable = nullptr;
    LookUpScopeTable = nullptr;

    // Task B
    delete[] collisionRecord;
  }

  ScopeTable *getLookupScopeTable() { return this->LookUpScopeTable; }
  ScopeTable *getCurrrentScopeTable() { return this->curScopeTable; }

  // Task B
  CollisionNodes *getCollisionRecords() { return this->collisionRecord; }
  int getTotalScopeTable() { return this->scopeUniqueNumber; }
  double getMeanRatio()
  {
    double meanRatio = 0.0;
    for (int i = 0; i <= this->scopeUniqueNumber; i++)
    {
      if (collisionRecord[i].tableId != -1)
      {
        meanRatio += (1.0 * collisionRecord[i].collision /
                      collisionRecord[i].bucketSize);
      }
    }
    meanRatio /= this->scopeUniqueNumber;
    return meanRatio;
  }
  void printCollisionRecords() 
  {
    for (int i = 0; i < this->scopeUniqueNumber; i++)
    {
      if (collisionRecord[i].tableId != -1)
      {
        //  cout<< "ScopeTable# " << collisionRecord[i].tableId + 1
        //     << " | Collisions: " << collisionRecord[i].collision
        //     << " | Bucket Size: " << collisionRecord[i].bucketSize
        //     << " | Collision Ratio: "
        //     << (1.0 * collisionRecord[i].collision /
        //         collisionRecord[i].bucketSize)
        //     << endl;
      }
    }
  }
  int get_current_scope_table_id()
  {
    if(this->curScopeTable!=nullptr)
    {
      return this->curScopeTable->getUnique_number() ;
    }
    else
  {
    return -1;
  }
  }
  int st_offset()
  {
    return this->curScopeTable->get_global_st_offset();
  }
};

#endif