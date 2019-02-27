#include "SpeechPrepro.h"

SpeechPrepro::SpeechPrepro(xml_node<> * desc,Service * p) :Service(desc,p) {

    TRACEPRINT(1) cout << "Using Speech Prepro" << endl;

    string language = getSourceLanguage();

    char buf[1024];
    memset(buf, 0, sizeof(buf));
    if (readlink("/proc/self/exe", buf, sizeof(buf)-1) < 0) {
      cerr << "readlink error" << endl;
      exit(-1);
    }
    string path = string(buf);
    string command = ""; 

    if (language == "en") {
       path = string(EN_SPEECH_PREPRO_COMMAND); 
       TRACEPRINT(3) cout << "Path:" << path << endl;
       command = string("perl ")+path; 	
    } else if (language == "de"){ 
       path = string(DE_SPEECH_PREPRO_COMMAND);
       TRACEPRINT(3) cout << "Path:" << path << endl;
       command = string("perl ")+path;
    } else { 
       path = string(SPEECH_PREPRO_COMMAND);
       TRACEPRINT(3) cout << "Path:" << path << endl;
       command = string("perl ")+path+string(" -lang=")+language;
    } 
    speechPreproStream.open( command.c_str(), std::ios_base::out | std::ios_base::in );

    
}

SpeechPrepro::~SpeechPrepro() {

}

void SpeechPrepro::preprocess(Segment * seg) {

    TRACEPRINT(2) cout << "Input to Speech Prepro:" << seg->text << endl;
    speechPreproStream << seg->text << "\n";
    speechPreproStream.flush();
    getline(speechPreproStream,seg->text);
    TRACEPRINT(2) cout << "Output to Speech Prepro:" << seg->text << endl;


}
void SpeechPrepro::postprocess(Segment * seg) {


    TRACEPRINT(2) cout << "Input to Speech Postpro:" << seg->text << endl;
    string::size_type Pos; 
    while(string::npos != (Pos = seg->text.find("<f>"))) {
      seg->text.replace(Pos,3,"");
    }
    while(string::npos != (Pos = seg->text.find("</f>"))) {
      seg->text.replace(Pos,4,"");
    }
    TRACEPRINT(2) cout << "Output to Speech Postpro:" << seg->text << endl;


}

