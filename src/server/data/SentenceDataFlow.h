/*
 * PipelineManager.h
 *
 *  Created on: 31.05.2016
 *      Author: jniehues
 */

#ifndef SENTENCEDATAFLOW_H_
#define SENTENCEDATAFLOW_H_


#include "DataFlow.h"

#include <cstdlib>
#include <string>
#include <iostream>
#include <sstream>
#include "Segment.h"
#include <queue>
#include "DataFlow.h"
#include <climits>
#include <set>

using namespace std;

class SentenceDataFlow : public DataFlow {
private:
    queue<Segment> inputQueue;
    Segment currentSent;
    Segment preInput;

    set<char> punc;

    int maxCurrentSent;
    int currentSentWordCount;

    int lastStopTime;

    bool checkNewData();
    void getPreData(Text & result);

public:
    SentenceDataFlow();
    ~SentenceDataFlow();
    void input(const Segment & in);
    void markFinal();
    void clear();
    Text getData();
    //thread safe
    virtual void process(vector<Segment> & segments,Service * service);


};


#endif
