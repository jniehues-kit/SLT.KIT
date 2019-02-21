#include "PipelineManager.h"


PipelineManager::PipelineManager(xml_node<> * n) {
    init(n);

}

PipelineManager::PipelineManager(const char * filename) {
    ifstream myfile(filename);
    vector<char> * xmlFile = new vector<char>((istreambuf_iterator<char>(myfile)), istreambuf_iterator<char>( ));

    xmlFile->push_back('\0');

    updateServices = false;

    xml_document<> * xmlDoc = new xml_document<>;    // character type defaults to char
    xmlDoc->parse<0>((&(*xmlFile)[0]));    // 0 means default parse flags


    init(xmlDoc->first_node());

    delete xmlFile;
    delete xmlDoc;



}
PipelineManager::~PipelineManager() {
    delete service;
    delete connection;
    delete data;
}

void PipelineManager::init(xml_node<> * desc) {

    translator = NULL;

    updator = NULL;

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "service") == 0) {
            service = ServiceFactory::createService(node,Service::getRoot());
        }else if (strcmp(node->name(), "connection") == 0) {
            connection = ConnectionFactory::createConnection(node,this);
        }else if (strcmp(node->name(), "data") == 0) {
            data = DataFlow::create(node);
        }else if (strcmp(node->name(), "updateServices") == 0) {
	  updateServices = string(trim(node->value())).compare("1") == 0;
        }

    }

    if(updateServices) {
      service->updateServices();
    }

}


void PipelineManager::start() {
    connection->start();

}


void PipelineManager::onlyInput(const Segment & in) {
  data->input(in);
    cout << "Input:" << in.text << endl;
}

void PipelineManager::input(const Segment & in) {

    data->input(in);
    cout << "Input:" << in.text << endl;

      

    accesstranslator.lock();
    cout << "Check translator:" << translator << endl;
    if(translator == NULL) {
        cout << "Start translator" << endl;
        vector<Segment> d = data->getData();
        translator = new thread([=] { process(d);});
    }else {
        cout << "Translator still running -> No new translation" << endl;
    }
    accesstranslator.unlock();

}

void PipelineManager::update() {

  service->updateServices();

  accessUpdator.lock();
  updator = NULL;
  accessUpdator.unlock();

}

void PipelineManager::process(vector<Segment> segments) {

  if(updateServices) {
    accessUpdator.lock();
    if(updator == NULL) {
      updator = new thread([=] {update();});
    }
    accessUpdator.unlock();
  }

    data->process(segments,service);

    cout << "Data translationed" << endl;

    accesstranslator.lock();
    cout << "Reset translator ..." << endl;
    translator = NULL;
    cout << "Reset Done" << translator << endl;
    accesstranslator.unlock();

    connection->send(segments);

    cout << "Data send" << endl;


}

void PipelineManager::markFinal() {
    data->markFinal();

}

void PipelineManager::clear() {
    data->clear();
}

void PipelineManager::finalize() {
    //generate Translation
    accesstranslator.lock();
    if(translator == NULL) {
        cout << "Start translator" << endl;
        vector<Segment> d = data->getData();
        translator = new thread([=] { process(d); } );
    }else {
        cout << "Translator still running -> No new translation" << endl;
    }
    accesstranslator.unlock();
}





