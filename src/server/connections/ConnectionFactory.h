#ifndef CONNECTION_FACTORY_H_
#define CONNECTION_FACTORY_H_
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

using namespace std;


#include <fstream>
#include <cstring>
#include <cstdlib>
#include <iostream>
#include <vector>

#include "rapidxml.hpp"
#include "rapidxml_print.hpp"

#include "Connection.h"
#ifdef ICELIB
#include "ICEConnection.h"
#endif
#ifdef MEDIATOR
#include "MediatorConnection.h"
#endif

#include "util.h"

using namespace std;
using namespace rapidxml;

class ConnectionFactory {
private:

public:
    ConnectionFactory();
    static Connection * createConnection(xml_node<> * n, PipelineManager * p);
    static Connection * createConnection(const char * filename,PipelineManager * p);
};


#endif
