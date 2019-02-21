#ifndef SMART_CASE_H_
#define SMART_CASE_H_



#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"
#include <stdio.h>
#include <string.h>
#include <pstreams/pstream.h>
using redi::pstream;

#include <vector>


using namespace std;
using namespace rapidxml;

#define MOSES_CASE_COMMAND "/opt/mosesdecoder/scripts/recaser/truecase.perl"

class Smartcase: public Service {
private:

    string model;
    int mode;
    bool useMoses;
    pstream mosesStream;


    void parseXML(xml_node<> * desc);

public:
    Smartcase(xml_node<> * desc,Service * p);
    ~Smartcase();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
};


#endif
