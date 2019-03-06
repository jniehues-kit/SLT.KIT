/*
 * PipelineManager.h
 *
 *  Created on: 31.05.2016
 *      Author: jniehues
 */

#ifndef WORDDATAFLOW_H_
#define WORDDATAFLOW_H_


#include "DataFlow.h"

#include <cstdlib>
#include <string>
#include <iostream>
#include <sstream>
#include "Segment.h"
#include <queue>
#include "DataFlow.h"
#include <set>
#include <climits>

using namespace std;

class WordDataFlow : public DataFlow {
private:

    int lastStopTime;
    //final, but not yet decoded
    Segment currentSent;
    //already once decoded
    Segment lastSent;
    //not yet decoded
    Segment preInput;

    bool lastWordPunc;

    set<string> puncChars;

    int maxContext;
    int paragraphSize;
    int puncCount;
    int noIntermediateOutput;

    bool checkNewData();

    void parseXML(xml_node<> * desc);
    string removePunc(const string in);
    string recase(const string in);

public:
    WordDataFlow(xml_node<> * desc);
    ~WordDataFlow();
    void input(const Segment & in);
    void markFinal();
    void clear();
    Text getData();
    //thread safe
    virtual void process(vector<Segment> & segments,Service * service);


};


#endif
