#include "ServiceFactory.h"


Service * ServiceFactory::createService(xml_node<> * n,Service * p) {
    xml_node<> * c = n->first_node("type");
    string type = trim(c->value());
    if(type.compare("ReplaceTable") == 0) {
        return new ReplaceTable(n,p);
#ifdef AMUNLIB
    }else if(type.compare("AMUN") == 0) {
        return new AMUNWrapper(n,p);
    }else if(type.compare("BPE") == 0) {
	    return new BPEService(n,p);
#endif
#ifdef LAMTRAMLIB
    }else if(type.compare("Lamtram") == 0) {
        return new LamtramWrapper(n,p);
#endif
    }else if(type.compare("XNMT") == 0) {
        return new XNMT(n,p);
    }else if(type.compare("OpenNMT") == 0) {
        return new OpenNMT(n,p);
    }else if(type.compare("PythonPrepro") == 0) {
        return new PythonPrepro(n,p);
    }else if(type.compare("Smartcase") == 0) {
        return new Smartcase(n,p);
    }else if(type.compare("MLTargetToken") == 0) {
        return new MLTargetToken(n,p);

#ifdef LMDB
    }else if(type.compare("AnnotationDB") == 0) {
        return new AnnotationDB(n,p);
#endif
    }else if(type.compare("Detokenize") == 0) {
        return new Detokenize(n,p);
    }else if(type.compare("Cache") == 0) {
        return new Cache(n,p);
    }else if(type.compare("SpeechPrepro") == 0) {
        return new SpeechPrepro(n,p);
    }else if(type.compare("CaseMarkup") == 0) {
        return new CaseMarkup(n,p);
    }else {
        cerr << "Unkown Service: " << type << endl;
        exit(-1);
    }

}
Service * ServiceFactory::createService(const char * filename) {
    ifstream myfile(filename);
    vector<char> * xmlFile = new vector<char>((istreambuf_iterator<char>(myfile)), istreambuf_iterator<char>( ));

    xmlFile->push_back('\0');

    xml_document<> * xmlDoc = new xml_document<>;    // character type defaults to char
    xmlDoc->parse<0>((&(*xmlFile)[0]));    // 0 means default parse flags

    Service * s = createService(xmlDoc->first_node(),Service::getRoot());

    delete xmlFile;
    delete xmlDoc;

    return s;

}
