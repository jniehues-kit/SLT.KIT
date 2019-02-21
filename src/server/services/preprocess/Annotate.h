
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#ifndef ANNOTATE_H_
#define ANNOTATE_H_

#ifdef LMDB


#include <lmdb++.h>
#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"
#include "ServiceFactory.h"
#include <sstream>
#include <algorithm>
#include <cstring>
#include <map>

#ifdef MONGODB
#include <bsoncxx/builder/stream/document.hpp>
#include <bsoncxx/json.hpp>

#include <mongocxx/client.hpp>
#include <mongocxx/instance.hpp>
#include <mongocxx/exception/exception.hpp>
#endif


using namespace std;
using namespace rapidxml;



class AnnotationDB: public Service {
private:
    string dbfile;

    bool multiWord;

    lmdb::env env;

#ifdef MONGODB    
    mongocxx::instance inst;
    string mdb_address;
    bsoncxx::types::b_date last_date;
    bsoncxx::types::b_date current_date;
    
    Service * sourcePrepro;
    Service * targetPrepro;

    string wordListFile;
    map<string,int> wordList;

    bool dynamicUpdate;
    string sourcePreproFile;
    string targetPreproFile;

    void getNamesFromDB(vector<pair<string,string> > & phrases);
    void getPhrasesFromDB(vector<pair<string,string> > & phrases);
    void addNewPhrases(vector<pair<string,string> > & phrases);
    void insertPlaceholder(string ngram);
    void loadWordList();
    

#endif

    void parseXML(xml_node<> * desc);
    void preprocessSingleWord(Segment * seg);
    void preprocessMultiWord(Segment * seg);
    void loadWords(string & text,vector<string> & words);
    void findPhrases(vector<string> & words,map<int,map<int,string> > & phrases);
    void selectPhrases(int size, map<int,map<int,string> > & phrases,vector<pair<pair<int,int>,string> > & segmentation);

public:
    AnnotationDB(xml_node<> * desc,Service * p);
    ~AnnotationDB();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
    virtual void update();
};

#endif
#endif
