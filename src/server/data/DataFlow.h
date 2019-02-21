/*
 * PipelineManager.h
 *
 *  Created on: 31.05.2016
 *      Author: jniehues
 */

#ifndef DATAFLOW_H_
#define DATAFLOW_H_

class SentenceDataFlow;
#include <cstdlib>
#include <string>
#include <iostream>
#include <cstring>

#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Segment.h"
#include "Service.h"

using namespace std;
using namespace rapidxml;


class DataFlow {
private:

public:
    DataFlow() {};
    ~DataFlow() {};
    virtual void input(const Segment & in) {};
    virtual void markFinal() {};
    virtual void clear() {};
    virtual Text getData() {};
    virtual void process(vector<Segment> & segments,Service * service) {};

    static DataFlow* create(xml_node<> * n);
};


#endif
