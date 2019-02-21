#ifndef PYTHON_PREPRO_H_
#define PYTHON_PREPRO_H_



#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"

#include <Python.h>

using namespace std;
using namespace rapidxml;

class PythonPrepro: public Service {
private:
    PyObject * ppreproMeth;

    int tokenize;
    int ignoreCase;

    void parseXML(xml_node<> * desc);

public:
    PythonPrepro(xml_node<> * desc,Service * p);
    ~PythonPrepro();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
};


#endif
