#ifndef SYMBOLTABLE_HEADER
#define SYMBOLTABLE_HEADER

#include <iostream>
#include <string>

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
    newScopeTable->setUnique_number(++this->scopeUniqueNumber);
    newScopeTable->setHashFunction(this->hashFn);
    curScopeTable = newScopeTable;
    if (isPrint)
       cout<< "\tScopeTable# " << this->scopeUniqueNumber << " created" << endl;
  }

  void ExitScope()
  {
    ScopeTable *tmpSymbol = curScopeTable;
    curScopeTable = curScopeTable->getParentScope();
    if (isPrint)
       cout<< "\tScopeTable# " << tmpSymbol->getUnique_number() << " removed"
          << endl;
    delete tmpSymbol;
    return;
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

  bool Remove(string symbolName) { return curScopeTable->Delete(symbolName); }

  SymbolInfo *LookUp(string symbolName)
  {
    ScopeTable *tmpTable = curScopeTable;
    while (tmpTable != nullptr)
    {
      SymbolInfo *symbol = tmpTable->LookUp(symbolName);
      if (symbol != nullptr)
      {
        this->LookUpScopeTable = tmpTable;
        return symbol;
      }
      tmpTable = tmpTable->getParentScope();
    }

    return nullptr;
  }

  void PrintCurrentScopeTable() { curScopeTable->Print(); }

  void PrintAllScopeTable()
  {
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

  // extra

  SymbolTable(int total_num_buckets, HashFunction hashFn, bool isPrint = true)
  {
    this->total_num_buckets = total_num_buckets;
    this->curScopeTable = nullptr;
    this->LookUpScopeTable = nullptr;
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
    for (int i = 0; i < this->scopeUniqueNumber; i++)
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
         cout<< "ScopeTable# " << collisionRecord[i].tableId + 1
            << " | Collisions: " << collisionRecord[i].collision
            << " | Bucket Size: " << collisionRecord[i].bucketSize
            << " | Collision Ratio: "
            << (1.0 * collisionRecord[i].collision /
                collisionRecord[i].bucketSize)
            << endl;
      }
    }
  }
};

#endif