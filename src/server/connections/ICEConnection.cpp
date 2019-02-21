/*
 * S2STranslationServer.cpp
 *
 *  Created on: 19.12.2011
 *      Author: jniehues
 */

#include "ICEConnection.h"
#ifdef ICELIB


WorkerCallbackI::WorkerCallbackI(PipelineManager * s) : WorkerCallback() {
  server = s;
}

void WorkerCallbackI::init(const Ice::Current&) {

}

void WorkerCallbackI::process_async(const TranslationService::AMD_WorkerCallback_processPtr & cb, const string & input,const Ice::Current&) {
  cout << "Process:" << input << endl;
  Segment in;
  in.text = input;
  in.startTime = time(NULL);
  in.stopTime = time(NULL);
  cout << "Time:" << in.startTime << " - " << in.stopTime << endl;
  server->input(in);
  server->markFinal();
  callback = new TranslationService::AMD_WorkerCallback_processPtr(cb);
}





string WorkerCallbackI::simpleProcess(const string & input,const Ice::Current&) {
  callback = NULL;
  ready = false;

  cout << "Simple Process:" << input << endl;
  Segment in;
  in.text = input;
  in.startTime = time(NULL);
  in.stopTime = time(NULL);
  cout << "Time:" << in.startTime << " - " << in.stopTime << endl;
  server->onlyInput(in);
  server->markFinal();
  server->finalize();
  std::unique_lock<std::mutex> lk(m);
  cv.wait(lk, [&]{return ready;});


  string r = result;
  lk.unlock();
  cv.notify_one();

  server->clear();
  cout << "Translation to send:" << r << endl;
  return r;
}


void WorkerCallbackI::send(const Text r) {


    result = "";
    for(int i = 0; i < r.size(); i++) {
      result.append(r[i].text+ " ");
    }
    if(callback != NULL)  {
      cout << "Translation to send:" << result << endl;
      (*callback)->ice_response(result);
    }else {
      {
	std::lock_guard<std::mutex> lk(m);
        ready = true;
      }
      cv.notify_one();
    }


}

string WorkerCallbackI::finalize(const Ice::Current&) {
	server->finalize();
	return "";
}
void WorkerCallbackI::breakServer(const Ice::Current&) {
	server->clear();
}



ICEConnection::ICEConnection(xml_node<> * desc,PipelineManager * p) : Connection(desc,p){
    sourceLanguage = "";
    targetLanguage = "";
    
	username = "test";
	password = "test";

    config="";

    parseXML(desc);

    server = p;

    if(config == "") {
      cerr << "No ICE config given" << endl;
      exit(-1);
    }

}

ICEConnection::~ICEConnection() {

}


void ICEConnection::start() {

	  Ice::InitializationData initData;
	  initData.properties = Ice::createProperties(); // Workaround for a bug in Glacier2::Application                                                                                                   

	  
	  string arg = "--Ice.Config="+config;

	  char * arguments[2];
	  char a[arg.length() + 1];
	  strcpy(a,arg.c_str());
	  arguments[0] = a;
	  arguments[1] = a;
	    


	  this->main(2,arguments,initData);

}


Glacier2::SessionPrx ICEConnection::createSession() {
  Glacier2::SessionPrx session;
  while(true) {
    cout << "Connect to mediator " << endl;
    
    try
      {
	session = router()->createSession(username,password);
	break;
      }
    catch(const Ice::LocalException& ex)
      {
	cerr << "Communication with the server failed:\n" << ex << endl;
      }
    sleep(1000);
  }
  return session;

}

void ICEConnection::sessionDestroyed() {
        cerr << "Session destroyed " << endl;
	restart();
}

void ICEConnection::send(const Text result) {
  worker->send(result);
}

int ICEConnection::runWithSession(int argc, char*[]) {

	cout << "Add Worker" << endl;
        TranslationService::MediatorPrx session = TranslationService::MediatorPrx::uncheckedCast(this->session());
	worker = new WorkerCallbackI(server);
        session->addWorker(TranslationService::WorkerCallbackPrx::uncheckedCast(addWithUUID(worker)),sourceLanguage,targetLanguage);
        do
        {
            string s;
            cout << "";
            getline(cin, s);
            if(!s.empty())
            {
                if(s[0] == '/')
                {
                    if(s == "/quit")
                    {
                        break;
                    }
                }
            }
        }
        while(cin.good());
        return EXIT_SUCCESS;


}



void ICEConnection::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "sourceLanguage") == 0) {
            sourceLanguage = trim(node->value());
        }else if (strcmp(node->name(), "targetLanguage") == 0) {
            targetLanguage = trim(node->value());
        }else if (strcmp(node->name(), "config") == 0) {
            config = trim(node->value());
	}
    }

}


#endif
