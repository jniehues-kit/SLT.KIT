#include "OpenNMT.h"

OpenNMT::OpenNMT(xml_node<> * desc,Service * p) :Service(desc,p) {

    TRACEPRINT(1) cout << "Using OpenNMT" << endl;
    
    model = "";
    postCommand = "";

    parseXML(desc);
    
    if(model == "") {
      cerr << "No Model for OpenNMT specified" << endl;
      exit(-1);
    }


#ifdef CMD_CONNECTION
    translateStream.open(OPENNMT_PY_COMMAND,std::ios_base::out | std::ios_base::in);
    cout << OPENNMT_PY_COMMAND << endl;
    cout << "Waiting ..." << endl;
    string s;
    getline(translateStream,s);
    TRACEPRINT(2) cout << "Output to OpenNMT-py:" << s << endl;
    sleep(2);
    TRACEPRINT(2) cout << "Testing pipe" << endl;
    translateStream << "this is a test" << "\n";
    translateStream.flush();
    string t;
    getline(translateStream,t);
    TRACEPRINT(2) cout << "Output to OpenNMT Test: " << t << endl;
#else
    string module = "onmt";
    string className = "OnlineTranslator";
    string methode = "translate";

    cout << "Create Python object" << endl;
    

    PyGILState_STATE gstate;
    gstate = PyGILState_Ensure();

    
    PyObject * pmod   = PyImport_ImportModule(module.c_str());
    if(pmod == NULL) {
      cerr << "Cannot load Python modul:" << module << endl;
      PyErr_Print();
      exit(-1);
    }
    PyObject * pclass = PyObject_GetAttrString(pmod, className.c_str());
    if(pclass == NULL) {
      cerr << "Cannot load Python class:" << className << endl;
      PyErr_Print();
      exit(-1);
    }
    PyObject * pargs  = Py_BuildValue("(s)",model.c_str());
    if(pargs == NULL) {
      cerr << "Cannot parse arguments:" << model << endl;
      PyErr_Print();
      exit(-1);
    }
    PyObject * pinst  = PyEval_CallObject(pclass, pargs);
    if(pinst == NULL) {
      cerr << "Cannot init object from class:" << className << endl;
      PyErr_Print();
      exit(-1);
    }
    pmeth  = PyObject_GetAttrString(pinst, methode.c_str());
    if(pmeth == NULL) {
      cerr << "Cannot init methode:" << methode << endl;
      PyErr_Print();
      exit(-1);
    }

    
    Py_DECREF(pmod);
    Py_DECREF(pclass);
    Py_DECREF(pargs);
    Py_DECREF(pinst);
    PyGILState_Release(gstate);

    cout << "Python creation Done" << endl;
#endif
    
   

    if(postCommand.compare("") != 0) {
      
      postStream.open( postCommand.c_str(), std::ios_base::out | std::ios_base::in );

    }

}

OpenNMT::~OpenNMT() {

}


void OpenNMT::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "model") == 0) {
            model = trim(node->value());
        }else if (strcmp(node->name(), "postprocess") == 0) {
            postCommand = trim(node->value());
        }
    }

}


void OpenNMT::preprocess(Segment * seg) {

    TRACEPRINT(2) cout << "Input to OpenNMT:" << seg->text << endl;
#ifdef CMD_CONNECTION
    translateStream << seg->text << "\n";
    translateStream.flush();
    getline(translateStream,seg->text);
#else
    cout << "Start using threads: " << PyEval_ThreadsInitialized() << endl;
    PyGILState_STATE gstate;
    gstate = PyGILState_Ensure();
    cout << "Got state" << endl;
    char * cstr;
    PyObject * pargs  = Py_BuildValue("(s)", seg->text.c_str());
    cout << "Call Methods" << endl;
    PyObject * pres   = PyEval_CallObject(pmeth, pargs);         
    cout << "Got result" << endl;
    PyArg_Parse(pres, "s", &cstr);
    string result(cstr);
    Py_DECREF(pargs);
    Py_DECREF(pres);
    cout << "Release state" << endl;
    PyGILState_Release(gstate);
    cout << "Release state done" << endl;
    seg->text = result;
#endif
    TRACEPRINT(2) cout << "Output to OpenNMT:" << seg->text << endl;

}
void OpenNMT::postprocess(Segment * seg) {

    TRACEPRINT(2) cout << "Input to OpenNMT Postprocess:" << seg->text << endl;

    postStream << seg->text  << "\n";
    postStream.flush();
    getline(postStream,seg->text);
    TRACEPRINT(2) cout << "Output to OpenNMT Postprocess:" << seg->text << endl;

}

