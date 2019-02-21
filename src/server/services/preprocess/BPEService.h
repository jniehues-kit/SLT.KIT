
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#ifndef BPE_SERVICE_H_
#define BPE_SERVICE_H_

#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"
#include <sstream>
#include <cstring>
#include <Python.h>

using namespace std;
using namespace rapidxml;

class BPEService: public Service {
private:
    string codec;

    PyObject * ppreproMeth;

    void parseXML(xml_node<> * desc);
public:
    BPEService(xml_node<> * desc,Service * p);
    ~BPEService();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
};

#endif
