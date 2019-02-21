#include "MLTargetToken.h"

MLTargetToken::MLTargetToken(xml_node<> * desc,Service * p) :Service(desc,p) {

    TRACEPRINT(1) cout << "Using ML Target Token" << endl;

    filename = "";

    parseXML(desc);

}

MLTargetToken::~MLTargetToken() {

}

void MLTargetToken::preprocess(Segment * seg) {

    TRACEPRINT(2) cout << "Input to MLTargetToken" << seg->text << endl;
    /*
    string result;
    string word;
    stringstream s (stringstream::in | stringstream::out);
    s << seg->text << " ";
    while(!s.eof()) {
        s >> word;
        if(!s.eof()) {
            if(word[0] == '@') {
                while(word.compare("}") != 0) {
                    result.append(word);
                    result.append(" ");
                    s >> word;
                }
                result.append(word);
                result.append(" ");
            }else {
                result.append(splitWord(word));
                result.append(" ");
            }
        }
    }
    */
    seg->text = langID + " " + seg->text;


    TRACEPRINT(2) cout << "Output of MLTargetToken" << seg->text << endl;

}
void MLTargetToken::postprocess(Segment * seg) {


}

void MLTargetToken::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "targetToken") == 0) {
            langID = trim(node->value());
        }
    }

}

