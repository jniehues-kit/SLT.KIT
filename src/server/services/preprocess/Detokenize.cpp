#include "Detokenize.h"

Detokenize::Detokenize(xml_node<> * desc,Service * p) :Service(desc,p) {

    TRACEPRINT(1)   cout << "Using Detokenize" << endl;

    puncChars.push_back(".");
    puncChars.push_back("!");
    puncChars.push_back(",");
    puncChars.push_back(":");
    puncChars.push_back("?");


}

Detokenize::~Detokenize() {


}

void Detokenize::preprocess(Segment * seg) {


}
void Detokenize::postprocess(Segment * seg) {

    TRACEPRINT(2)    cout << "Input to Detokenize Postprocessing" << seg->text << endl;

    string result = " "+seg->text+" ";
    string::size_type Pos;

    for(int i = 0; i < puncChars.size(); i++) {
        string match = " " + puncChars[i];
        while (string::npos != (Pos = result.find(match))) {
            result.replace(Pos, match.length(), puncChars[i]);
        }
    }

    seg->text = trim(result);

    if(seg->type == PREL_PART_SENTENCE) {
        size_t lastChar = seg->text.find_last_not_of(" ");
        if(lastChar != string::npos && seg->text[lastChar] != '.' && seg->text[lastChar] != '>') {
            seg->text.resize(lastChar+1);
            if(seg->text[lastChar] == '.') {
                seg->text.append("..");
            }else {
                seg->text.append("...");
            }
        }
    }



    TRACEPRINT(2) cout << "Output of Detokenize Postprocessing" << seg->text << endl;

}
