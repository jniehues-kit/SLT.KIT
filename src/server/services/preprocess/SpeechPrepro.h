#ifndef SPEECH_PREPRO_H_
#define SPEECH_PREPRO_H_


#include <pstreams/pstream.h>
using redi::pstream;
#include <stdio.h>
#include <string.h>

#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"

#define SPEECH_PREPRO_COMMAND "/../lib/perl/prepro_Speech.pl"
#define EN_SPEECH_PREPRO_COMMAND "/../lib/perl/speech_prepro_en.pl" 
#define DE_SPEECH_PREPRO_COMMAND "/../lib/perl/speech_prepro_de.pl" 

using namespace std;
using namespace rapidxml;

class SpeechPrepro: public Service {
private:

    pstream speechPreproStream;


public:
    SpeechPrepro(xml_node<> * desc,Service * p);
    ~SpeechPrepro();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
};


#endif
