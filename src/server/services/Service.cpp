#include "Service.h"
#include "ServiceFactory.h"


Service::Service() {
    tLevel = 0;
    sourceLanguage = "";
    targetLanguage = "";
}

Service::Service(xml_node<> * desc,Service * p) {
    childXML = NULL;
    child = NULL;
    tLevel = -1;
    sourceLanguage = "";
    targetLanguage = "";

    parent = p;

    parseXML(desc);
    if(childXML != NULL) {
        child = ServiceFactory::createService(childXML,this);
    }
}

Service::~Service() {
    delete child;
}

void Service::process(Segment * seg) {
	if(trim(seg->text).compare("") == 0) {
		TRACEPRINT(2) cout << "Ignore empty segment" << endl;
		return;
	}
    preprocess(seg);
    if(child) {
       child->process(seg);
    }
    postprocess(seg);
}

void Service::processForward(Segment * seg) {
	if(trim(seg->text).compare("") == 0) {
		TRACEPRINT(2) cout << "Ignore empty segment" << endl;
		return;
	}
    preprocess(seg);
    if(child) {
       child->processForward(seg);
    }
}

void Service::updateServices() {
  update();
    if(child) {
       child->updateServices();
    }
}


void Service::clear() {
    clearService();
    if(child) {
       child->clear();
    }
}

void Service::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "service") == 0) {
            childXML = node;
        }else if (strcmp(node->name(), "traceLevel") == 0) {
            tLevel = atoi(node->value());
        }else if (strcmp(node->name(), "sourceLanguage") == 0) {
            sourceLanguage = trim(node->value());
        }else if (strcmp(node->name(), "targetLanguage") == 0) {
            targetLanguage = trim(node->value());
        }
    }

}

int Service::traceLevel() {
    if(tLevel != -1) {
        return tLevel;
    }else if(parent != NULL) {
        return parent->traceLevel();
    }else {
        return 0;
    }
}

string Service::getSourceLanguage() {
    if(sourceLanguage.compare("") != 0) {
        return sourceLanguage;
    }else if(parent != NULL) {
        return parent->getSourceLanguage();
    }else {
        return "";
    }
}

string Service::getTargetLanguage() {
    if(targetLanguage.compare("") != 0) {
        return targetLanguage;
    }else if(parent != NULL) {
        return parent->getTargetLanguage();
    }else {
        return "";
    }
}


Service * Service::getRoot() {
    return new Service();
}
