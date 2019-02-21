/*
 * ICEConnection.h
 *
 *  Created on: 31.05.2016
 *      Author: jniehues
 */
#ifndef ICECONNECTION_H_
#define ICECONNECTION_H_
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#ifdef ICELIB

#include <IceUtil/IceUtil.h>
#include <Ice/Ice.h>
#include <Glacier2/Glacier2.h>

#include <Mediator.h>

#include <time.h>
#include <iostream>
#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include <sstream>
#include <string>
#include <limits>
#include <stack>
#include <mutex>
#include <thread>
#include "Connection.h"
#include "PipelineManager.h"
#include <mutex>
#include <condition_variable>
using namespace std;
using namespace rapidxml;


class WorkerCallbackI : public TranslationService::WorkerCallback {
 private:
	std::mutex m;
	std::condition_variable cv;
	string result;
	bool ready;
	TranslationService::AMD_WorkerCallback_processPtr * callback;

  PipelineManager * server;
 public:
  WorkerCallbackI(PipelineManager * s);
  virtual void init(const Ice::Current&);
  virtual void process_async(const TranslationService::AMD_WorkerCallback_processPtr & cb, const string & input,const Ice::Current&);
  virtual string simpleProcess(const string & input,const Ice::Current&);
  //virtual void process(const string & input,const Ice::Current&);
  virtual string finalize(const Ice::Current&);
  virtual void breakServer(const Ice::Current&);


	void send(const Text result);

};


class ICEConnection : public Connection,public Glacier2::Application{
 private:


	string sourceLanguage;
	string targetLanguage;
	string config;

	string username;
	string password;


	WorkerCallbackI * worker;


	PipelineManager * server;

	void parseXML(xml_node<> * desc);

public:
	ICEConnection(xml_node<> * desc,PipelineManager * p);
	virtual ~ICEConnection();
	void start();
	Glacier2::SessionPrx createSession();
	void sessionDestroyed();
	int runWithSession(int argc, char*[]);
	void send(const Text result);

};
#endif /* ICELIB */
#endif /* MTECCONNECTION_H_ */
