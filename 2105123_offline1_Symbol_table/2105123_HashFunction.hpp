#ifndef HASH_FUNCTION_HEADER
#define HASH_FUNCTION_HEADER

#include <iostream>
#include <string>
using namespace std;

typedef unsigned int (*HashFunction)(string, unsigned int);

class Hash
{
public:
  // given
  static unsigned int SDBMHash(string str, unsigned int num_buckets)
  {
    unsigned int hash = 0;
    unsigned int len = str.length();
    for (unsigned int i = 0; i < len; i++)
    {
      hash = ((str[i]) + (hash << 6) + (hash << 16) - hash) % num_buckets;
    }
    return hash;
  }
  
  // http://www.cse.yorku.ca/~oz/hash.html
  static unsigned int DJB2Hash(string str, unsigned int num_buckets)
  {
    unsigned int hash = 5381;
    for (char c : str)
      hash = ((hash << 5) + hash) + c;
    return hash % num_buckets;
  }

  static unsigned int AdditiveHash(string str, unsigned int num_buckets)
  {
    unsigned int hash = 0;
    for (char c : str)
      hash += c;
    return hash % num_buckets;
  }

  static unsigned int FNV1aHash(string str, unsigned int num_buckets)
  {

    const unsigned int fnv_prime = 0x01000193; 
    unsigned int hash = 0x811C9DC5;            
    for (char c : str)
    {
      hash ^= c;
      hash *= fnv_prime;
    }
    return hash % num_buckets;
  }
};

#endif