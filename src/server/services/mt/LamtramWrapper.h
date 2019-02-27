#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#ifndef LAMTRAM_WRAPPER_H_
#define LAMTRAM_WRAPPER_H_
#ifdef LAMTRAMLIB


#include <lamtram/neural-lm.h>
#include <lamtram/encoder-decoder.h>
#include <lamtram/encoder-attentional.h>
#include <lamtram/encoder-classifier.h>
#include <lamtram/multitask-encoder-attentional.h>
#include <lamtram/model-utils.h>
#include <lamtram/string-util.h>
#include <lamtram/ensemble-decoder.h>
#include <lamtram/macros.h>
#include <dynet/dict.h>

#include <cstring>

#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "Service.h"

#include <pstreams/pstream.h>
using redi::pstream;


using namespace std;
using namespace rapidxml;


class LamtramWrapper: public Service {
private:
    vector<lamtram::NeuralLMPtr> lms;
    vector<lamtram::EncoderDecoderPtr> encdecs;
    vector<lamtram::EncoderAttentionalPtr> encatts;
    vector<shared_ptr<dynet::Model> > models;
    lamtram::DictPtr vocab_src, vocab_trg;
    vector<lamtram::MultiTaskModelPtr> mtmodels;
    vector<lamtram::DictPtr> vocabs_trg_temp;
    vector<lamtram::DictPtr> vocabs_src_temp;
    shared_ptr<lamtram::EnsembleDecoder> decoder;

    string model;
    int voc_src;
    int voc_trg;
    float word_pen,unk_pen;
    int max_len,beam;
    string ensemble_op;
      bool use_fixed_length;
    string dynetMem;

    string postCommand;
    pstream postStream;



    void parseXML(xml_node<> * desc);

    void loadModels();
    
public:
    LamtramWrapper(xml_node<> * desc,Service * p);
    ~LamtramWrapper();
    virtual void preprocess(Segment * seg);
    virtual void postprocess(Segment * seg);
};

#endif
#endif
