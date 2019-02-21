/*
 * PipelineManager.h
 *
 *  Created on: 31.05.2016
 *      Author: jniehues
 */

#ifndef PIPELINEMANAGER_H_
#define PIPELINEMANAGER_H_


class PipelineManager;
#include <cstdlib>
#include <string>
#include <iostream>
#include <thread>
#include <mutex>
#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "ConnectionFactory.h"
#include "ServiceFactory.h"
#include "DataFlow.h"

using namespace std;
using namespace rapidxml;

class PipelineManager {
private:

    Connection * connection;
    Service * service;

    std::thread * translator;
    std::thread * updator;
    std::mutex accesstranslator;
    std::mutex accessUpdator;
    bool updateServices;

    DataFlow * data;

    void init(xml_node<> * n);

    void process(vector<Segment> data);
    void update();
    void parseXML(xml_node<> * desc);

public:
    PipelineManager(xml_node<> * n);
    PipelineManager(const char * filename);
    ~PipelineManager();
    void start();
    void clear();
    void finalize();
    void input(const Segment &);
    void onlyInput(const Segment &);
    void markFinal();
};

#endif
