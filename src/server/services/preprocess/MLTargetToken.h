#ifndef MLTARGETTOKEN_H_
#define MLTARGETTOKEN_H_



#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"
#include <map>
#include <sstream>
#include <cstdlib>
#include <cstring>
#include <fstream>

#include <Python.h>

using namespace std;
using namespace rapidxml;

class MLTargetToken: public Service {
private:
    string filename;
    PyObject * pmeth;


    void parseXML(xml_node<> * desc);

    string langID; 

public:
    MLTargetToken(xml_node<> * desc,Service * p);
    ~MLTargetToken();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
};


#endif
