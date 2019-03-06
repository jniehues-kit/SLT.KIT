#include "DataFlow.h"
#include "SentenceDataFlow.h"
#include "WordDataFlow.h"


DataFlow* DataFlow::create(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "type") == 0) {
            string t = trim(node->value());
            if(t.compare("Sentence") == 0) {
                return new SentenceDataFlow(desc);
            }else if(t.compare("Word") == 0) {
                return new WordDataFlow(desc);
            }else {
                cerr << "Unkown data flow:" << t << endl;
                exit(-1);
            }
        }
    }
}
