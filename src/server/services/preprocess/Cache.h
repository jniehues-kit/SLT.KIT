#ifndef CACHE_H_
#define CACHE_H_



#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"

#include <map>
#include <vector>

using namespace std;
using namespace rapidxml;

class Cache: public Service {
private:
    map<string,string> cache;
    map<string,string> TM;

public:
    Cache(xml_node<> * desc,Service * p);
    ~Cache();
    virtual void process(Segment * seg);
    virtual void clearService();
};


#endif
