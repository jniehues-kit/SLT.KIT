/*
 * S2STranslationServer.cpp
 *
 *  Created on: 19.12.2011
 *      Author: jniehues
 */

#include "MediatorConnection.h"


#ifdef MEDIATOR

MediatorConnection::MediatorConnection(xml_node<> * desc,PipelineManager * p) : Connection(desc,p){
    sourceLanguage = "";
    targetLanguage = "";
    sourceLanguageType = "text";
    targetLanguageType = "text";
    host = "";
    port = -1;

    ignoreFlush = false;

    cloudP = NULL;
    outputStopTime = std::numeric_limits<int>::min();
    lastStopTime = std::numeric_limits<int>::min();
    lastStartTime = 0;
    offset = -1;

    ignoreOffset = false;

    name = "KITTranslationService";

    parseXML(desc);

    if(host == "" || port == -1) {
        cerr << "No host or port given" << endl;
        exit(-1);
    }

    if(sourceLanguage == "" || targetLanguage == "") {
        cerr << "No language given" << endl;
        exit(-1);
    }
    server = p;
    name += "_"+sourceLanguage+"-"+targetLanguage;
    initConnection();
}

MediatorConnection::~MediatorConnection() {

}


void MediatorConnection::start() {
    char *streamID = NULL;
    while(true) {
        int err = 0;

        if(mcloudConnect(cloudP,host.c_str(),port) != 0) {
            cerr << "Could not connect" << endl;
            sleep(500);
            continue;
        }
        cerr << "Connected to server" << host << ":" << port << endl;

        while ( 1 ) {
          MCloudPacket *p = NULL;
          char *sessionID = NULL;
          int proceed = 1;

          //reset everything;
          breakServer();

          cout << "Waiting for client" << endl;
          if ( mcloudWaitForClient (cloudP,&streamID) != 0 ) {
            fprintf (stderr, "ERROR while waiting for client.\n");
            break;
          }
          fprintf (stderr, "INFO received client request ==> waiting for packages.\n");

          while ( proceed && (p = mcloudGetNextPacket (cloudP)) != NULL ) {
            switch (p->packetType) {
            case MCloudData:
              if (sessionID == NULL || strcmp(sessionID, p->sessionID) != 0) {
                fprintf (stderr, "INFO connected to session %s\n", p->sessionID);
                sessionID = p->sessionID;
              }
              mcloudProcessDataAsync (cloudP, p, this);
              break;
            case MCloudDone:
              cout << "Start Done" << endl;
              mcloudWaitFinish (cloudP,MCloudProcessingQueue,1);
              fprintf (stderr, "INFO received DONE message ==> waiting for clients.\n");
              proceed = 0;
              break;
            case MCloudFlush:
		    if(!ignoreFlush) {
			    cout << "Start Flush" << endl;
			    mcloudWaitFinish (cloudP, MCloudProcessingQueue,0); /* incoming new
                                                                    packages should not be added with mcloudProcessDataAsync until this
                                                                    function returns */
			    cout << "before flush" << endl; 
			    mcloudSendFlush (cloudP); /* inform other workers to flush */
			    cout << "after flush" <<endl; 
		    }
              break;
            case MCloudError:
          cout << "Start Error" << endl;
              mcloudBreak (cloudP,MCloudProcessingQueue);
              fprintf (stderr, "INFO received ERROR message ==> waiting for clients.\n");
              proceed = 0;
              break;
            case MCloudReset:
              mcloudBreak (cloudP,MCloudProcessingQueue);
              fprintf (stderr, "INFO received RESET message ==> waiting for clients.\n");
              proceed = 0;
              break;
            default:
              fprintf (stderr, "ERROR unknown packet type %d\n", p->packetType);
              proceed = 0;
              err = 1;
            }
        cout << "Wihle Loop MTEC Server" << endl;
          }

          if ( p == NULL ) {
            fprintf (stderr, "ERROR while waiting for messages.\n");
            err = 1;
          }

          if ( err ) break;
        }

        fprintf (stderr, "WARN connection terminated ==> trying to reconnect.\n");


    }
}


Text MediatorConnection::checkDouble(Text result) {

    //skip first message if already send. if the whole sentence was there but not final
    if(result.size() > 0 && lastMessage.startTime == result[0].startTime && lastMessage.stopTime == result[0].stopTime) {
        string t1 = lastMessage.text;
        size_t p = t1.find_last_not_of(" ");
        if(p != string::npos) {
            t1.resize(p+1);
        }
        string t2 = result[0].text;
        p = t2.find_last_not_of(" ");
        if(p != string::npos) {
            t2.resize(p+1);
        }
        if(t1.compare(t2) == 0) {
            result.erase(result.begin());
        }
    }
    if(result.size() > 0) {
        lastMessage = result[result.size() -1];
    }
    return result;
}

Text MediatorConnection::preprocess(const Text in) {

    Text result;

    stringstream final;
    stringstream temp;
    int oldStartTimeOfUnfinishedSegment = -1;
    if(lastInput.size() > 0) {
        int i = 0;
        while(i < lastInput.size() && lastInput[i].stopTime < in[0].startTime) {
            cout << "Compare:"  << i << " " << lastInput[i].startTime << " < " << in[0].startTime << endl;
            if(lastInput[i].text[0] != '<') {
                final << lastInput[i].text << " ";
            }
            i++;
        }
	if(i < lastInput.size()) {
	  oldStartTimeOfUnfinishedSegment = lastInput[i].startTime;
	}
        if(final.str().compare("") != 0 ) {
            Segment f;
            f.text = final.str();
            f.startTime = lastInput[0].startTime;
            f.stopTime = lastInput[i-1].stopTime;
            result.push_back(f);
        }
    }

    for (int i = 0; i < in.size(); i++) {
        if(in[i].text[0] != '<') {
            temp << in[i].text << " ";
        }
    }

    Segment t;
    t.text = temp.str();

    if(oldStartTimeOfUnfinishedSegment != -1 && oldStartTimeOfUnfinishedSegment < in[0].startTime) {
      t.startTime = oldStartTimeOfUnfinishedSegment;
    }else{
      t.startTime = in[0].startTime;
    }

    t.stopTime = in[in.size()-1].stopTime;
    result.push_back(t);

    lastInput = in;

    if(oldStartTimeOfUnfinishedSegment != -1 && oldStartTimeOfUnfinishedSegment < in[0].startTime) {
      lastInput[0].startTime = oldStartTimeOfUnfinishedSegment;
    }
    return result;
}

void MediatorConnection::process(const Segment input) {
        cout << "Input Start Time:" << input.startTime << endl;
        cout << "Last stop Time:" << lastStopTime << endl;
        if(input.startTime >= lastStopTime) {
            server->markFinal(); // start new segment
        }else if(input.startTime != lastStartTime) {
            cout << "ERROR: Overwriting segments with different start times" << endl;
            cout << "Last Message:" << lastStartTime << " " << lastStopTime << endl;
            cout << "New Message:" << input.startTime << " " << input.stopTime << endl;
        }
        server->input(input);
        lastStartTime = input.startTime;
        lastStopTime = input.stopTime;
    }
void MediatorConnection::send(const Text result) {


        Text r = checkDouble(result);

        for(int i = 0; i < result.size(); i++) {
            string startTime = getTime(result[i].startTime);
            string stopTime = getTime(result[i].stopTime);
            cout << "Output Message Timestap: " << startTime << " " << stopTime << " " << result[i].startTime << " " << result[i].stopTime << endl;

            MCloudPacket *p = mcloudPacketInitFromText (cloudP, startTime.c_str(), stopTime.c_str(), result[i].startTime, result[i].stopTime,GetTargetLanguage().c_str(), result[i].text.c_str());
            mcloudSendPacketAsync (cloudP, p, NULL);
        }


}


int MediatorConnection::getTimeOffset(char * time, int off) {
    if(ignoreOffset) {
        tm t;
        int milliseconds;
        sscanf (time, "%d/%d/%d-%d:%d:%d.%d", &t.tm_mday, &t.tm_mon, &t.tm_year, &t.tm_hour, &t.tm_min, &t.tm_sec, &milliseconds);
        t.tm_mon -= 1;
        t.tm_year -= 1900;
        if ( mktime(&t) == -1 ) {
            cerr << "Cannot understand time" << endl;
        }
        double timeSpend = ((long) mktime(&t)) *1000 + milliseconds;
        return timeSpend-offset;

    }else {
        return off;
    }
}
void MediatorConnection::setTimeOffset(char * time, int off) {
    if(ignoreOffset) {
        if(offset == -1) {
            tm t;
            int milliseconds;
            sscanf (time, "%d/%d/%d-%d:%d:%d.%d", &t.tm_mday, &t.tm_mon, &t.tm_year, &t.tm_hour, &t.tm_min, &t.tm_sec, &milliseconds);
            t.tm_mon -= 1;
            t.tm_year -= 1900;
            if ( mktime(&t) == -1 ) {
                cerr << "Cannot understand time" << endl;
            }
            offset = ((long) mktime(&t)) *1000 + milliseconds;


        }
        return;
    }
    tm t;
    int milliseconds;
    sscanf (time, "%d/%d/%d-%d:%d:%d.%d", &t.tm_mday, &t.tm_mon, &t.tm_year, &t.tm_hour, &t.tm_min, &t.tm_sec, &milliseconds);
    t.tm_mon -= 1;
    t.tm_year -= 1900;
    if ( mktime(&t) == -1 ) {
        cerr << "Cannot understand time" << endl;
    }
    long newOffset = ((long) mktime(&t)) *1000 + milliseconds - off;
    if(abs(offset - newOffset) > 1 ) {
        cout << "Change offset" << endl;
        cout << "Start Time:" << mktime(&t) *1000 + milliseconds << endl;
        cout << "Milliseconds:" << milliseconds << endl;
	cout << "Old offset:" << offset << endl;
        offset = newOffset;
        cout << "Offset:" << offset << endl;
    }

}
string MediatorConnection::getTime(int duration) {
    cout << "Duration: " << duration << " Output time:" << offset + duration << endl;
    int msec = (offset + duration)%1000;
    if(msec < 0) {
        msec = 1000 + msec;
    }
    cout << "Msec:" << msec << endl;
    long time = (offset + duration)/1000;
    if(time < 0) {
        time -= 1;
    }
    tm * t = localtime(&time);
    char str[2000];
    sprintf (str, "%02d/%02d/%02d-%02d:%02d:%02d.%03d", t->tm_mday, t->tm_mon+1, t->tm_year+1900, t->tm_hour, t->tm_min, t->tm_sec, msec);
    return string(str);
}

void MediatorConnection::finalize() {
    server->finalize();
}



void MediatorConnection::initConnection() {

    /* Connect and Process */
    if ( (cloudP = mcloudCreate ("smt", MCloudModeWorker)) == NULL ) {
        fprintf (stderr, "ERROR creating Cloud Object.\n");
        exit(-1);
      }



    mcloudAddService(cloudP,name.c_str(),"smt",sourceLanguage.c_str(),sourceLanguageType.c_str(),targetLanguage.c_str(),targetLanguageType.c_str(),"");
    mcloudSetInitCallback (cloudP, initCallback, this);
    mcloudSetDataCallback (cloudP, dataCallback);
    mcloudSetFinalizeCallback (cloudP, finalizeCallback, this);
    mcloudSetErrorCallback (cloudP, MCloudProcessingQueue,errorCallback, this);
    mcloudSetBreakCallback (cloudP, MCloudProcessingQueue,breakCallback, this);


}




void MediatorConnection::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "sourceLanguage") == 0) {
            sourceLanguage = trim(node->value());
        }else if (strcmp(node->name(), "targetLanguage") == 0) {
            targetLanguage = trim(node->value());
        }else if (strcmp(node->name(), "sourceLanguageType") == 0) {
            sourceLanguageType = trim(node->value());
        }else if (strcmp(node->name(), "targetLanguageType") == 0) {
            targetLanguageType = trim(node->value());
        }else if (strcmp(node->name(), "host") == 0) {
            host = trim(node->value());
        }else if (strcmp(node->name(), "port") == 0) {
            port = atoi(node->value());
	}else if(strcmp(node->name(), "ignoreFlush") == 0) {
		ignoreFlush = atoi(node->value());
        }else if (strcmp(node->name(), "ignoreOffset") == 0) {
            ignoreOffset = atoi(node->value());
        }
    }

}


void  MediatorConnection::breakServer() {

    outputStopTime = std::numeric_limits<int>::min();
    lastStopTime = std::numeric_limits<int>::min();
    lastStartTime = 0;
    offset = -1;

    server->clear();
}


void  MediatorConnection::clear() {

    server->clear();
}

int initCallback(MCloud *cP, MCloudPacket *p, void *s) {
    
    MediatorConnection  *server = (MediatorConnection*) s;

    cerr << ">>>> initCallback\n";

    return 0;

}

int  dataCallback (MCloud *cP, MCloudPacket *p, void *s) {

    MediatorConnection  *server = (MediatorConnection*) s;

    switch (p->dataType) {
    case MCloudText:{

        if(server->getSourceLanguageType() == "text") {

            char *text = NULL;
            mcloudPacketGetText (cP, p, &text);
            //cerr, ">>>> dataCallback: %s\n", text;

            cout << "Input Message Timestamp: " << p->start << " " << p->stop << " " << p->startOffset << " " << p->stopOffset << endl;
            cout << "Input message:" << text << endl;

            Segment in;

            server->setTimeOffset(p->start,p->startOffset);


            in.text = text;
            in.startTime = server->getTimeOffset(p->start,p->startOffset);
            in.stopTime = server->getTimeOffset(p->stop,p->stopOffset);
            server->process(in);

            free (text);
            text = NULL;

        }else if(server->getSourceLanguageType() == "unseg-text") {

            //ASR protokoll is a little bit different -> they do not overwrite the whole last message


	  cout << "Input Message:" << p->start << " " << p->stop << " " << p->startOffset << " " << p->stopOffset << " " << endl;

            server->setTimeOffset(p->start,p->startOffset);

            Text input;

            MCloudWordToken *tokenA = NULL;
            int tokenN = 0;
            cout << "Get tokens"  << endl;
            mcloudPacketGetWordTokenA (cP, p, &tokenA, &tokenN);
            cout << tokenN << "Tokens got" << endl;
            for (int i = 0; i < tokenN; i++) {
	      if(tokenA[i].startTime - tokenA[i].stopTime > 0) {
                //Ignore zero length segments because they are error of ASR
		Segment in;
                in.text = tokenA[i].internal;
                in.startTime = tokenA[i].startTime;
                in.stopTime = tokenA[i].stopTime;
                input.push_back(in);
		cout << "Input segment:" << in.text << " " << in.startTime << " " << in.stopTime << endl;
	      }else {
		cout << "Ignore Input segment:" << tokenA[i].internal << " " << tokenA[i].startTime << " " << tokenA[i].stopTime << endl;		
	      }
            }
	    if(input.size() > 0) {
	      cout << "start preprocess" << endl;
	      Text prepro = server->preprocess(input);

	      for (int i = 0; i < prepro.size(); i++) {
                cout << "Translate: " << prepro[i].text << " " << prepro[i].startTime << " " << prepro[i].stopTime << endl;
                server->process(prepro[i]);
	      }
	    }

            free(tokenA);
            tokenA = NULL;

        }


    }
        break;
    default:
        fprintf (stderr, "ERROR Unsupported data type %d.\n", p->dataType);
    }

    return 0;
}

int finalizeCallback (MCloud *cP, void *s) {

    MediatorConnection  *server = (MediatorConnection*) s;
    //SMT_Handle smtH = data->smtH;

    server->finalize();


    return 0;
}

int breakCallback (MCloud *cP, void *s) {

    MediatorConnection  *server = (MediatorConnection*) s;

    server->breakServer();

    return 0;
}

int errorCallback (MCloud *cP, void *s) {

    MediatorConnection  *server = (MediatorConnection*) s;

    server->breakServer();

    return 0;
}

#endif