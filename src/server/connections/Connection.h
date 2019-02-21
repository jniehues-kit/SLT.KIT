#ifndef CONNECTION_H_
#define CONNECTION_H_

class PipelineManager;
#include <cstdlib>
#include <string>
#include <iostream>
#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Segment.h"
//#include "PipelineManager.h"
using namespace std;
using namespace rapidxml;

class Connection {
private:


public:
    Connection(xml_node<> * desc,PipelineManager * p);
    virtual void start(){};
    virtual void send(const Text result){};
};

#endif
