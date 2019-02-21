/*
 * MTecConnection.h
 *
 *  Created on: 31.05.2016
 *      Author: jniehues
 */

#ifndef MEDIATORCONNECTION_H_
#define MEDIATORCONNECTION_H_
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif


#ifdef MEDIATOR

#include <time.h>
#include <iostream>
#include "MCloud.h"
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
using namespace std;
using namespace rapidxml;



class MediatorConnection : public Connection{
 private:


	string sourceLanguage;
	string targetLanguage;
	string sourceLanguageType;
	string targetLanguageType;
	string host;
	int port;
	string workerName;

	PipelineManager * server;

	bool ignoreFlush;

	Segment lastMessage;
	Text lastInput;

	string name;

	MCloud *cloudP;
	int lastStopTime;
	int lastStartTime;
	int outputStopTime;
	long offset;
	int ignoreOffset;

	void parseXML(xml_node<> * desc);
	void initConnection();

	void sendDone();

	Text checkDouble(Text result);
public:
	MediatorConnection(xml_node<> * desc,PipelineManager * p);
	virtual ~MediatorConnection();
	void start();
    void send(const Text result);
    void process(const Segment input);
	void breakServer();
	void clear();
	Text preprocess(const Text text);
	void finalize();
	inline string & GetTargetLanguage() {return targetLanguage;};
	virtual void setTimeOffset(char * time, int offset);
	virtual int getTimeOffset(char * time, int offset);
	virtual string getTime(int offset);
	string getSourceLanguageType() {return sourceLanguageType;};

};

int initCallback(MCloud *cP, MCloudPacket *p, void *server);
int dataCallback (MCloud *cP, MCloudPacket *p, void *server);
int finalizeCallback (MCloud *cP, void *server);
int breakCallback (MCloud *cP, void *server);
int errorCallback (MCloud *cP, void *server);

#endif

#endif /* MTECCONNECTION_H_ */
