/*
 * mainModular.cpp
 *
 *  Created on: 31.05.2011
 *      Author: jniehues
 */

#include <iostream>
#include "PipelineManager.h"

using namespace std;

using namespace std;

int main(int args,char ** argv) {

    Py_Initialize();
    PyEval_InitThreads();

    PyThreadState *_save;

    _save = PyEval_SaveThread();

    if(args == 2) {
        PipelineManager * server = new PipelineManager(argv[1]);
        server->start();
        delete server;
    }else {
        cout << "Usage: " << argv[0] << " ParameterFile" << endl;
    }


}
