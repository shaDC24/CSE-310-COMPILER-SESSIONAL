#ifndef SCOPETABLE_HEADER
#define SCOPETABLE_HEADER

#include <iostream>
#include <string>

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

  unsigned int hashFunction(string symbolName)
  {
    unsigned int hashValue = (hashFn(symbolName, num_buckets));

    return (hashValue);
  }
  int position(int hashValue) { return (hashValue + 1); }

public:
  bool Insert(string symbolName, string symbolType)
  {
    SymbolInfo *symbol = new SymbolInfo(symbolName, symbolType);
    unsigned int hashValue = hashFunction(symbolName);
    SymbolInfo *current = buckets[hashValue];
    int localChainIndex = 1;
    if (current == nullptr)
    {
      buckets[hashValue] = symbol;
      setPositionIndex(position(hashValue));
      setChainIndex(localChainIndex);
      return true;
    }

    SymbolInfo *prev = nullptr;
    while (current != nullptr)
    {
      if (current->getsymbolName() == symbolName)
      {
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

    return true;
  }

  SymbolInfo *LookUp(string symbolName)
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
    for (int i = 0; i < num_buckets; i++)
    {
      cout << "\t" << (i + 1) << "-->";
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

  ScopeTable(int numBuckets)
  {
    this->num_buckets = numBuckets;
    buckets = new SymbolInfo *[this->num_buckets]();
    for (int i = 0; i < num_buckets; i++)
    {
      buckets[i] = nullptr;
    }
    // Task B
    this->collisionCount = 0;
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
};

#endif