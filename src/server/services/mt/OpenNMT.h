#ifndef OPENMT_H_
#define OPENNMT_H_


#include <Python.h>


#include <pstreams/pstream.h>
using redi::pstream;

#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"

#define OPENNMT_PY_COMMAND "python /opt/lib/OpenNMT-py/online.py"
//#define CMD_CONNECTION

using namespace std;
using namespace rapidxml;

class OpenNMT: public Service {
private:

  //pstream stream;
    string model;

#ifdef CMD_CONNECTION
    pstream translateStream;
#else
    PyObject * pmeth;
#endif

    string postCommand;
    pstream postStream;


    void parseXML(xml_node<> * desc);

public:
    OpenNMT(xml_node<> * desc,Service * p);
    ~OpenNMT();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
};


#endif
