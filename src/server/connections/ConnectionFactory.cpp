#include "ConnectionFactory.h"


Connection * ConnectionFactory::createConnection(xml_node<> * n,PipelineManager * p) {
    xml_node<> * c = n->first_node("type");
    string type = trim(c->value());
#ifdef MEDIATOR
    if(type.compare("Mediator") == 0) {
        return new MediatorConnection(n,p);
    }else {
        cerr << "Unkown Connection: " << type << endl;
        exit(-1);
    }
#endif

}
Connection * ConnectionFactory::createConnection(const char * filename,PipelineManager * p) {
    ifstream myfile(filename);
    vector<char> * xmlFile = new vector<char>((istreambuf_iterator<char>(myfile)), istreambuf_iterator<char>( ));

    xmlFile->push_back('\0');

    xml_document<> * xmlDoc = new xml_document<>;    // character type defaults to char
    xmlDoc->parse<0>((&(*xmlFile)[0]));    // 0 means default parse flags

    Connection * s = createConnection(xmlDoc->first_node(),p);

    delete xmlFile;
    delete xmlDoc;

    return s;

}
