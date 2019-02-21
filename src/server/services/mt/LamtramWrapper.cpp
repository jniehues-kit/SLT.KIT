#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#include "LamtramWrapper.h"
#ifdef LAMTRAMLIB

using namespace lamtram;
using namespace dynet;
using namespace std;

LamtramWrapper::LamtramWrapper(xml_node<> * desc,Service * p) : Service(desc,p) {

    voc_src = 0;
    voc_trg = 0;
    word_pen = 0.f;
    unk_pen = 0.f;
    ensemble_op = "sum";
    max_len = 200;
    beam = 1;
    use_fixed_length = false;
    dynetMem = "4700";

    parseXML(desc);
    TRACEPRINT(1) cout << "Using lamtram Wrapper" << endl;
    postCommand = "";


    char * arguments[3];
    string d ="--dynet_mem";
    char a[d.length() +1];
    char b[dynetMem.length() +1];
    strcpy(a,d.c_str());
    strcpy(b,dynetMem.c_str());
    arguments[0] = a;
    arguments[1] = a;
    arguments[2] = b;
    
    char *argv[] = {&a[0],&a[0], &b[0]};
    char ** e = &argv[0];
    int argc = 3;

    dynet::initialize(argc, e);

    loadModels();


    if(postCommand.compare("") != 0) {
      
      postStream.open( postCommand.c_str(), std::ios_base::out | std::ios_base::in );

    }


}

LamtramWrapper::~LamtramWrapper() {

  
}


void LamtramWrapper::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "model") == 0) {
            model = trim(node->value());
        }else if (strcmp(node->name(), "voc_src") == 0) {
            voc_src = atoi((trim(node->value())).c_str());
        }else if (strcmp(node->name(), "voc_trg") == 0) {
            voc_trg = atoi((trim(node->value())).c_str());
        }else if (strcmp(node->name(), "word_pen") == 0) {
            word_pen = atof((trim(node->value())).c_str());
        }else if (strcmp(node->name(), "unk_pen") == 0) {
            unk_pen = atof((trim(node->value())).c_str());
        }else if (strcmp(node->name(), "ensemble_op") == 0) {
            ensemble_op = trim(node->value());
        }else if (strcmp(node->name(), "beam") == 0) {
            beam = atoi((trim(node->value())).c_str());
        }else if (strcmp(node->name(), "use_fixed_length") == 0) {
            use_fixed_length = atoi((trim(node->value())).c_str());
        }else if (strcmp(node->name(), "max_len") == 0) {
            max_len = atoi((trim(node->value())).c_str());
        }else if (strcmp(node->name(), "max_len") == 0) {
            max_len = atoi((trim(node->value())).c_str());
        }else if (strcmp(node->name(), "postprocess") == 0) {
            postCommand = trim(node->value());
        }else if (strcmp(node->name(), "dynet_mem") == 0) {
            dynetMem = trim(node->value());
        }
    }

}

void LamtramWrapper::preprocess(Segment * seg) {

    TRACEPRINT(2) cout << "Input to Lamtram" << seg->text << endl;

    if(seg->text.compare("") != 0) {
	    Sentence sent_src, sent_trg;
	    vector<string> str_src, str_trg;
	    Sentence align;
	    int fix_length = 0;
    
	    if(encdecs.size() + encatts.size() > 0) {
		    str_src = SplitWords(seg->text);
		    sent_src = ParseWords(*vocab_src, str_src, false);
	    }
	    
	    if(use_fixed_length) {
		    fix_length = seg->target_length;
	    }
	    EnsembleDecoderHypPtr trg_hyp = decoder->Generate(sent_src,fix_length);
	    if(trg_hyp.get() != nullptr) {
		    sent_trg = trg_hyp->GetSentence();
		    align = trg_hyp->GetAlignment();
		    str_trg = ConvertWords(*vocab_trg, sent_trg, false);
		    //MapWords(str_src, sent_trg, align, mapping, str_trg);
	    }
	    cout << PrintWords(str_trg) << endl;
	    seg->text = PrintWords(str_trg);
	    
    
    //translate with details
    /*if(seg->text.compare("") != 0) {
        if(seg->lattice.compare("") == 0) {
            seg->text = translator->translateSentence(seg->text);
        }else if(seg->translationDetails == 0) {
            seg->text = translator->translateLattice(seg->text,seg->lattice);
        }else {
            seg->text = translator->translateLatticeWithDetails(seg->text,seg->lattice);
        }
    }*/

    }
    TRACEPRINT(2) cout << "Output to Lamtram" << seg->text << endl;

}
void LamtramWrapper::postprocess(Segment * seg) {

    TRACEPRINT(2) cout << "Input to Lamtram Postprocess:" << seg->text << endl;
    if(postCommand.compare("") != 0) {
      postStream << seg->text  << "\n";
      postStream.flush();
      getline(postStream,seg->text);
    }
    TRACEPRINT(2) cout << "Output to Lamtram Postprocess:" << seg->text << endl;


}


void LamtramWrapper::loadModels() {
  cout << "Load" << endl;
  // Read in the files
  vector<string> infiles;
  boost::split(infiles, model, boost::is_any_of("|"));
  string type, file;
  for(string & infile : infiles) {

    cout << "Load: "  << infile << endl;
    int eqpos = infile.find('=');
    if(eqpos == string::npos)
      THROW_ERROR("Bad model type. Must specify encdec=, encatt=, or nlm= before model name." << endl << infile);
    type = infile.substr(0, eqpos);
    file = infile.substr(eqpos+1);
    DictPtr vocab_src_temp, vocab_trg_temp;
    shared_ptr<dynet::Model> mod_temp;
    // Read in the model
    if(type == "encdec") {
      EncoderDecoder * tm = ModelUtils::LoadBilingualModel<EncoderDecoder>(file, mod_temp, vocab_src_temp, vocab_trg_temp);
      encdecs.push_back(shared_ptr<EncoderDecoder>(tm));
    } else if(type == "encatt") {
      cout << "Load" << endl;
      EncoderAttentional * tm = ModelUtils::LoadBilingualModel<EncoderAttentional>(file, mod_temp, vocab_src_temp, vocab_trg_temp);
      cout << "Done" << endl;
      encatts.push_back(shared_ptr<EncoderAttentional>(tm));
    } else if(type == "nlm") {
      NeuralLM * lm = ModelUtils::LoadMonolingualModel<NeuralLM>(file, mod_temp, vocab_trg_temp);
      lms.push_back(shared_ptr<NeuralLM>(lm));
    } else if(type == "shared") {
      EncoderAttentional * tm = ModelUtils::LoadMultitaskModel<MultiTaskEncoderAttentional>(file, mod_temp, vocabs_src_temp, vocabs_trg_temp,mtmodels);
      encatts.push_back(shared_ptr<EncoderAttentional>(tm));
      vocab_src_temp = vocabs_src_temp[voc_src];
      vocab_trg_temp = vocabs_trg_temp[voc_trg];
      for(int i = 0; i < mtmodels.size(); i++) {mtmodels[i]->SetVocabulary(voc_src,voc_trg);};
    }
    
    cout << "Sanity check" << endl;
    // Sanity check
    if(vocab_trg.get() && vocab_trg_temp->get_words() != vocab_trg->get_words())
      THROW_ERROR("Target vocabularies for translation/language models are not equal.");
    if(vocab_src.get() && vocab_src_temp.get() && vocab_src_temp->get_words() != vocab_src->get_words())
      THROW_ERROR("Source vocabularies for translation/language models are not equal.");
    models.push_back(mod_temp);
    vocab_trg = vocab_trg_temp;
    if(vocab_src_temp.get()) vocab_src = vocab_src_temp;
  
  }
  int vocab_size = vocab_trg->size();
    
    cout << "create decoder" << endl;
  // Create the decoder
  decoder.reset(new EnsembleDecoder(encdecs, encatts, lms));
  decoder->SetWordPen(word_pen);
  decoder->SetUnkPen(unk_pen);
  decoder->SetEnsembleOperation(ensemble_op);
  decoder->SetBeamSize(beam);
  decoder->SetSizeLimit(max_len);
  if(use_fixed_length) {
    decoder->SetUseFixedLength(true);
  }
   
    cout << "done" << endl;
    
}


#endif
