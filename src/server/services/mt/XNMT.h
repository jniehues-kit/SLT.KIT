#ifndef XNMT_H_
#define XNMT_H_


#include <Python.h>


#include <pstreams/pstream.h>
using redi::pstream;

#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"

#define XNMT_COMMAND "/root/anaconda3/bin/python /opt/lib/xnmt/xnmt/lecture_translator.py"
#define CMD_CONNECTION

using namespace std;
using namespace rapidxml;

class XNMT: public Service {
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
    XNMT(xml_node<> * desc,Service * p);
    ~XNMT();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
};


#endif
