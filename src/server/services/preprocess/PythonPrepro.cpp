#include "PythonPrepro.h"

PythonPrepro::PythonPrepro(xml_node<> * desc,Service * p) :Service(desc,p) {

    TRACEPRINT(1) cout << "Using Python Prepro" << endl;

    tokenize = 0;
    ignoreCase = 0;

    parseXML(desc);


    string module = "ExtraPreprocessing";
    string className = "ExtraPreprocessing";
    string methodeName = "process";
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
    string sl = getSourceLanguage();
    if(sl.compare("de") == 0) {
        sl = "german";
    }else if(sl.compare("fr") == 0) {
        sl = "french";
    }else if(sl.compare("en") == 0) {
        sl = "english";
    }else if(sl.compare("it") == 0) {
        sl = "italian";
    }else if(sl.compare("es") == 0) {
        sl = "spanish";
    }else if(sl.compare("pt") == 0) {
        sl = "portuguese";
    }

      TRACEPRINT(3) cout << sl.c_str() << " " << tokenize << " " <<  ignoreCase << endl;
      PyObject * pargs  = Py_BuildValue("(sii)", sl.c_str(), tokenize, ignoreCase);
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

PythonPrepro::~PythonPrepro() {
    PyGILState_STATE gstate;
    gstate = PyGILState_Ensure();
    Py_DECREF(ppreproMeth);
    PyGILState_Release(gstate);

}

void PythonPrepro::preprocess(Segment * seg) {

    TRACEPRINT(2) cout << "Input to Python Prepro" << seg->text << endl;
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
    TRACEPRINT(2) cout << "Output of Python Prepro " << seg->text << endl;

}
void PythonPrepro::postprocess(Segment * seg) {


}

void PythonPrepro::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "tokenize") == 0) {
            tokenize = atoi(node->value());
        }else if (strcmp(node->name(), "ignoreCase") == 0) {
            ignoreCase = atoi(node->value());
        }
    }

}
