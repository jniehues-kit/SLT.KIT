
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#ifndef CASE_MARKUP_H_
#define CASE_MARKUP_H_


#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"
#include "ServiceFactory.h"
#include <map>
#include <set>
#include <locale>
#include <sstream>
#include <cstdlib>
#include <cstring>
#include <fstream> 
#include <boost/regex.hpp> 
#include <boost/locale.hpp>

#include <pstreams/pstream.h>
using redi::pstream;


#ifdef MONGODB
#include <bsoncxx/builder/stream/document.hpp>
#include <bsoncxx/json.hpp>

#include <mongocxx/client.hpp>
#include <mongocxx/instance.hpp>
#include <mongocxx/exception/exception.hpp>
#endif


using namespace std;
using namespace rapidxml;

class CaseMarkup: public Service {
private:

    string mflist;
    locale loc;

    void parseXML(xml_node<> * desc);
    int use_previous_punc;
    int ignore_punc_len; 
    map <string,string> caseSet;
    void loadMFcase();
    void insertCasemap(string input);


    string postCommand;
    pstream postStream;

#ifdef MONGODB    
    mongocxx::instance inst;
    string mdb_address;
    bsoncxx::types::b_date last_date;
    bsoncxx::types::b_date current_date;
    Service * sourcePrepro;
    string sourcePreproFile;

    bool dynamicUpdate;

    void getNamesFromDB();
    void getPhrasesFromDB();

    void checkPhrase(string & input);

#endif

public:
    CaseMarkup(xml_node<> * desc,Service * p);
    ~CaseMarkup();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
    virtual void update();
};

#endif
