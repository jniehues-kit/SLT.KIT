#ifndef DETOKENIZE_H_
#define DETOKENIZE_H_



#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"

#include <vector>

using namespace std;
using namespace rapidxml;

class Detokenize: public Service {
private:
    vector<string> puncChars;

public:
    Detokenize(xml_node<> * desc,Service * p);
    ~Detokenize();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
};


#endif
