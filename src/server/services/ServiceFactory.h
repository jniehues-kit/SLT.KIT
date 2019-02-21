#ifndef SERVICE_FACTORY_H_
#define SERVICE_FACTORY_H_

using namespace std;


#include <fstream>
#include <cstring>
#include <cstdlib>
#include <iostream>
#include <vector>

#include "rapidxml.hpp"
#include "rapidxml_print.hpp"

#include "Service.h"
#include "BPEService.h"
#ifdef LAMTRAMLIB
#include "LamtramWrapper.h"
#endif
#ifdef LMDB
#include "Annotate.h"
#endif

#include "OpenNMT.h"
#include "XNMT.h"
#include "ReplaceTable.h"
#include "PythonPrepro.h"
#include "Smartcase.h"
#include "Detokenize.h"
#include "SpeechPrepro.h"
#include "Cache.h"
#include "CaseMarkup.h"
#include "MLTargetToken.h"
#include "util.h"

using namespace std;
using namespace rapidxml;

class ServiceFactory {
private:

    Service * next;

public:
    ServiceFactory();
    static Service * createService(xml_node<> * n, Service * p);
    static Service * createService(const char * filename);
};


#endif
