#include "BPEService.h"

BPEService::BPEService(xml_node<> * desc,Service * p) : Service(desc,p) {

    codec = "";

    parseXML(desc);



    
    string module = "apply_bpe";
    string className = "BPE";
    string methodeName = "process_line";
    PyGILState_STATE gstate;
    gstate = PyGILState_Ensure();

   PyObject * pcodec   = PyImport_ImportModule("codecs");
    if(pcodec == NULL) {
        cerr << "Cannot load Python modul: codecs" << endl;
        exit(-1);
    }
   PyObject* open = PyObject_GetAttrString(pcodec,"open");
    if(open == NULL) {
        cerr << "Cannot load Python method: open" << endl;
        exit(-1);
    }
    PyObject * codec_param  = Py_BuildValue("(sss)", codec.c_str(),"r","utf-8");
    if(codec_param == NULL) {
      cerr << "Cannot load Python string: " << codec << endl;
        exit(-1);
    }
   PyObject* codec_file = PyObject_CallObject(open, codec_param);
    if(codec_file == NULL) {
        cerr << "Cannot create python file" << endl;
      PyErr_PrintEx(0);
        exit(-1);
    }


    
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

    //PyObject * pParam  = Py_BuildValue("o", codec_file);
    PyObject* const pParam = PyTuple_New(1);
    PyTuple_SetItem(pParam, 0, codec_file);
    //PyObject * pParam  = PyTuple_Pack(codec_file);
    if(pParam == NULL) {
      cerr << "Cannot build value: " << codec << endl;
        exit(-1);
    }
    PyObject * pinst  = PyEval_CallObject(pclass, pParam);
    if(pinst == NULL) {
      cerr << "Cannot init object from class:" << className << endl;
      PyErr_PrintEx(0);
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

