#ifndef SERVICE_H_
#define SERVICE_H_

using namespace std;

#include "Segment.h"

#include <cstdlib>
#include <string>
#include <iostream>
#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
//#include "ServiceFactory.h"
class ServiceFactory;

using namespace std;
using namespace rapidxml;

class Service {
private:

    xml_node<> * childXML;
    Service * parent;

    string sourceLanguage;
    string targetLanguage;
    int tLevel;

    void parseXML(xml_node<> * desc);

protected:
    Service * child;


public:
    Service();
    Service(xml_node<> * desc,Service * p);
    ~Service();
    virtual void updateServices();
    virtual void update(){};
    virtual void process(Segment * seg);
    virtual void processForward(Segment * seg);
    virtual void preprocess(Segment * seg) {};
    virtual void postprocess(Segment * seg) {};
    virtual void clear();
    virtual void clearService(){}
    virtual int traceLevel();
    virtual string getSourceLanguage();
    virtual string getTargetLanguage();
    static Service * getRoot();
};


#endif
