#ifndef REPLACE_TABLE_H_
#define REPLACE_TABLE_H_



#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"

#include <vector>

using namespace std;
using namespace rapidxml;

class ReplaceTable: public Service {
private:
    vector<pair<string,string> > replaceChars;
    vector<pair<string,string> > replaceCharsOnlyInput;

public:
    ReplaceTable(xml_node<> * desc,Service * p);
    ~ReplaceTable();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
};


#endif
