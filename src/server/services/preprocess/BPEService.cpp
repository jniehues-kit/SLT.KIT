#include "BPEService.h"

BPEService::BPEService(xml_node<> * desc,Service * p) : Service(desc,p) {

    codec = "";

    parseXML(desc);


    string module = "apply_bpe";
    string className = "BPE";
    string methodeName = "process_line";
    PyGILState_STATE gstate;
    gstate = PyGILState_Ensure();

    PyObject * pmod   = PyImport_ImportModule(module.c_str());
    if(pmod == NULL) {
        cerr << "Cannot load Python modul:" << module << endl;
        exit(-1);
    }
    PyObject * pclass = PyObject_GetAttrString(pmod, className.c_str());
    if(pclass == NULL) {
        cerr << "Cannot load Python class:" << className << endl;
        exit(-1);
    }

    PyObject * pargs  = Py_BuildValue("(sis)", codec, -1, "@@");
      if(pargs == NULL) {
          cerr << "Cannot parse arguments:" << endl;
          exit(-1);
      }
      PyObject * pinst  = PyEval_CallObject(pclass, pargs);
      if(pinst == NULL) {
          cerr << "Cannot init object from class:" << className << endl;
          exit(-1);
      }
      ppreproMeth  = PyObject_GetAttrString(pinst, methodeName.c_str());
      if(ppreproMeth == NULL) {
          cerr << "Cannot init methode:" << methodeName << endl;
          exit(-1);
      }

      Py_DECREF(pinst);
      Py_DECREF(pmod);
      Py_DECREF(pclass);

    PyGILState_Release(gstate);



}

BPEService::~BPEService() {
    PyGILState_STATE gstate;
    gstate = PyGILState_Ensure();
    Py_DECREF(ppreproMeth);
    PyGILState_Release(gstate);
}


void BPEService::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "codec") == 0) {
            codec = trim(node->value());
        }
    }

}

void BPEService::preprocess(Segment * seg) {

	TRACEPRINT(2) cout << "Input to BPE" << seg->text << endl;

	if(seg->text.compare("") != 0) {

        PyGILState_STATE gstate;
        gstate = PyGILState_Ensure();

        char * cstr;
        PyObject * pargs  = Py_BuildValue("(s)", seg->text.c_str());
        PyObject * pres   = PyEval_CallObject(ppreproMeth, pargs);         /* call process(input) */
        PyArg_Parse(pres, "s", &cstr);
        seg->text = string(cstr);
        Py_DECREF(pargs);
        Py_DECREF(pres);


        PyGILState_Release(gstate);

	}

	TRACEPRINT(2) cout << "Output to BPE" << seg->text << endl;

}
void BPEService::postprocess(Segment * seg) {

	TRACEPRINT(2) cout << "Input to Postprocess BPE" << seg->text << endl;

	string::size_type Pos;

	string result = seg->text;
        while (string::npos != (Pos = result.find("@@ "))) {
            result.replace(Pos, 3, "");
        }
	seg->text = result;

	TRACEPRINT(2) cout << "Output to Postprocess BPE" << seg->text << endl;

}

