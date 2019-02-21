#include "ReplaceTable.h"

ReplaceTable::ReplaceTable(xml_node<> * desc,Service * p) :Service(desc,p) {

    TRACEPRINT(1)    cout << "Using Replace Table" << endl;

    replaceChars.push_back(make_pair("@","_AT_"));
    replaceChars.push_back(make_pair("~","_TILDE_"));
    replaceChars.push_back(make_pair("|","_BAR_"));
    replaceChars.push_back(make_pair("#","_SHARP_"));
    replaceChars.push_back(make_pair("+","_PLUS_"));
    //  replaceChars.push_back(make_pair("%","_PERCENT_"));
    //Do hypins as in preprocessing
    replaceCharsOnlyInput.push_back(make_pair(" - "," %_HYP_% "));
    replaceCharsOnlyInput.push_back(make_pair("- "," _HYP_% "));
    replaceCharsOnlyInput.push_back(make_pair(" -"," %_HYP_ "));
    replaceCharsOnlyInput.push_back(make_pair("-"," _HYP_ "));
    replaceCharsOnlyInput.push_back(make_pair("_HYP_","-"));
    replaceCharsOnlyInput.push_back(make_pair("&#44;"," Komma "));
    replaceCharsOnlyInput.push_back(make_pair("&#32;"," "));
    replaceCharsOnlyInput.push_back(make_pair("& # 032 ;",""));


}

ReplaceTable::~ReplaceTable() {


}

void ReplaceTable::preprocess(Segment * seg) {

    TRACEPRINT(2) cout << "Input to ReplaceTable Preprocessing" << seg->text << endl;

    string result = " "+seg->text+" ";

    string::size_type Pos;


    for(int i = 0; i < replaceCharsOnlyInput.size(); i++) {
        while (string::npos != (Pos = result.find(replaceCharsOnlyInput[i].first))) {
            result.replace(Pos, replaceCharsOnlyInput[i].first.length(), replaceCharsOnlyInput[i].second);
        }
    }

    for(int i = 0; i < replaceChars.size(); i++) {
        while (string::npos != (Pos = result.find(replaceChars[i].first))) {
            result.replace(Pos, replaceChars[i].first.length(), replaceChars[i].second);
        }
    }
    trim(result);
    seg->text = result;

    TRACEPRINT(2) cout << "Output of ReplaceTable Preprocessing" << seg->text << endl;

}
void ReplaceTable::postprocess(Segment * seg) {

    TRACEPRINT(2) cout << "Input to ReplaceTable Postprocessing" << seg->text << endl;

    string result = " "+seg->text+" ";
    string::size_type Pos;
    for(int i = replaceChars.size()-1; i >= 0; i--) {
        while (string::npos != (Pos = result.find(replaceChars[i].second))) {
            result.replace(Pos, replaceChars[i].second.length(), replaceChars[i].first);
        }
    }

    seg->text = result;
    TRACEPRINT(2) cout << "Output of ReplaceTable Postprocessing" << seg->text << endl;

}
