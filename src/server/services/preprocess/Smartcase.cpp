#include "Smartcase.h"

Smartcase::Smartcase(xml_node<> * desc,Service * p) :Service(desc,p) {

    TRACEPRINT(1) cout << "Using Smart case" << endl;

    model = "";
    mode=8;
    useMoses=false;

    parseXML(desc);

    TRACEPRINT(1) cout << "Model:" << model << endl;

    if(useMoses) {
      char buf[1024];
      memset(buf, 0, sizeof(buf));
      if (readlink("/proc/self/exe", buf, sizeof(buf)-1) < 0) {
	cerr << "readlink error" << endl;
	exit(-1);
      }
      string path = string(buf);
      string command = ""; 
      command = string("perl ")+string(MOSES_CASE_COMMAND)+string(" --model ")+model;
      cout << command << endl;
      mosesStream.open( command.c_str(), std::ios_base::out | std::ios_base::in );
    }
}

Smartcase::~Smartcase() {


}

void Smartcase::preprocess(Segment * seg) {

    TRACEPRINT(2) cout << "Input to Smartcase:" << seg->text << endl;
    if(useMoses) {
      mosesStream << seg->text << "\n" ;
      mosesStream.flush();
      getline(mosesStream,seg->text);
    }

    TRACEPRINT(2) cout << "Output of Smartcase:" << seg->text << endl;

}
void Smartcase::postprocess(Segment * seg) {


}

void Smartcase::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "model") == 0) {
            model = trim(node->value());
        }else if (strcmp(node->name(), "mode") == 0) {
	  string m = trim(node->value());
	  if(m.compare("Moses") == 0) {
	    TRACEPRINT(1) cout << "Moses smartcase model" << endl;
	    useMoses=true;
	  }else{
	    cerr << "Unsupported mode:" << m << endl;
	  }
        }
    }

}
