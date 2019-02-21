#include "WordDataFlow.h"


WordDataFlow::WordDataFlow(xml_node<> * desc) {

    //maxCurrentSent = 0;

    //currentSentWordCount = 0;

    lastStopTime = INT_MIN;
    maxContext = 4;
    paragraphSize = 5;
    puncCount = 0;
    parseXML(desc);
    puncChars.insert(".");
    puncChars.insert("!");
    puncChars.insert(",");
    puncChars.insert(":");
    puncChars.insert("?");
    puncChars.insert("<br>");
    puncChars.insert("<br><br>");
    lastWordPunc = true;


}


void WordDataFlow::input(const Segment & in) {

    preInput = in;
    string::size_type Pos;
    string replace("...");
    while (string::npos != (Pos = preInput.text.find(replace))) {
        preInput.text.replace(Pos, replace.length(), "");
    }

}


void WordDataFlow::clear() {
    currentSent.text = "";
    currentSent.stopTime = 0;
    currentSent.startTime = 0;

    lastSent.text = "";
    lastSent.stopTime = 0;
    lastSent.startTime = 0;

    preInput.text = "";
    preInput.stopTime = 0;
    preInput.startTime = 0;

    lastStopTime = INT_MIN;
    lastWordPunc = true;
}

Text WordDataFlow::getData() {

    Text result;
    Segment s;
    if(!checkNewData()) {
        cout << "Ignore data because not new" << endl;
        return result;
    }

    if(lastSent.text.compare("") != 0 || currentSent.text.compare("") != 0 ) {

        if(lastSent.text.compare("") == 0) {
            lastSent.startTime = currentSent.startTime;
        }
        if(currentSent.text.compare("") != 0) {
            lastSent.stopTime = currentSent.stopTime;
        }
        lastSent.text = lastSent.text + " " +currentSent.text;

        currentSent.text = "";
        currentSent.startTime = currentSent.stopTime;
        lastSent.type = FINAL;
        result.push_back(lastSent);
    }
    preInput.type = PREL_PART_SENTENCE;
    result.push_back(preInput);

    for(int i = 0; i < result.size(); i++) {
        cout << i << "th data(" << result[i].type <<"):" << result[i].startTime << " - " << result[i].stopTime << " :" << result[i].text << endl;
    }

    lastStopTime = preInput.stopTime;
    return result;
}

void WordDataFlow::process(vector<Segment> & segments,Service * service) {


    if(segments.size() > 2) {
        cerr << "Too many segments for word data flow " << segments.size() << endl;
        exit(-1);
    }else if(segments.size() == 0) {
        return;
    }else if(segments.size() == 2) {
      cout << "SEG Segment 0" << segments[0].text <<  endl;
        service->process(&segments[0]);
	cout << "SEG Segment 0 results" << segments[0].text <<  endl;

        stringstream s (stringstream::in | stringstream::out);
        s << segments[0].text;
        s << " ";
        string word;
        vector<string> words;
        cout << "Last word Punc:" << lastWordPunc << endl;
        while(!s.eof()) {
            s >> word;

            if(!s.eof()) {
		    /*                if(lastWordPunc) {
		    cout << "Recase here 1:" << word[0] << endl;
                    word[0] = std::toupper( word[0] );
		    cout << "Recase here 1:" << word[0] << endl;
		    }*/
                words.push_back(word);
		/*                string last = word.substr(word.length()-1,1);
                if(puncChars.find(word) != puncChars.end() || puncChars.find(last) != puncChars.end()) {
                    if(strcmp(last.c_str(),",") != 0) {
			    cout << "Last wort Punc true because of :" << word << endl;
                        lastWordPunc = true;
                    }else{
			    cout << "Last wort Punc false because of :" << word << endl;
                        lastWordPunc = false;
                    }

                }else {
			    cout << "Last wort Punc false2 because of :" << word << endl;
                    lastWordPunc = false;
		    }*/
            }
        }



        if(words.size() > maxContext) {
	    vector<Segment> outSegments;
	    outSegments.resize(1);
	    int fixSegmentslength = 0;
            for(int i = 0; i < words.size() - maxContext; i++) {
		    if(lastWordPunc) {
			    cout << "Recase here 1:" << words[i] << endl;
			    words[i][0] = std::toupper( words[i][0] );
			    cout << "Recase here 1:" << word[0] << endl;
		    }
		    outSegments.back().text += words[i]+" ";
		    string last = words[i].substr(words[i].length()-1,1);
		    if(puncChars.find(words[i]) != puncChars.end() || puncChars.find(last) != puncChars.end()) {
		      if(strcmp(last.c_str(),",") != 0) {
                        puncCount ++;
                        if(puncCount % paragraphSize == 0) {
			  outSegments.back().text += "<br><br>";
			  fixSegmentslength += outSegments.back().text.length();
			  outSegments.resize(outSegments.size() + 1);
                        }
			    cout << "New Last wort Punc true because of :" << words[i] << endl;
                        lastWordPunc = true;
                    }else {
			    cout << "New Last wort Punc false because of :" << words[i] << endl;
                        lastWordPunc = false;

                    }
                }else {
			    cout << "New Last wort Punc false2 because of :" << words[i] << endl;
                        lastWordPunc = false;
                }
            }
            lastSent.text = "";
            for(int i = words.size() - maxContext; i < words.size(); i++) {
                lastSent.text += words[i]+" ";
                //currentSentWordCount ++;
            }
	    cout <<"SEG Finish:" << segments[0].text << endl;
	    cout << "SEG Keep:" << lastSent.text << endl;

	    fixSegmentslength += outSegments.back().text.length() + lastSent.text.length();

            segments[0].text = outSegments[0].text;
	    int stopTime= segments[0].stopTime;
	    segments[0].stopTime = 1.0 * segments[0].text.length()/fixSegmentslength * (stopTime - segments[0].startTime)+segments[0].startTime;
	    for(int i = 1; i < outSegments.size(); i++) {
	      segments.insert(segments.begin()+i,outSegments[i]);
	      segments[i].startTime = segments[i-1].stopTime;
	      segments[i].stopTime = 1.0 * segments[i].text.length()/fixSegmentslength * (stopTime - segments[0].startTime)+segments[i].startTime;
	    }
	      
	      

	      //Segments[0].stopTime = 1.0* lastSent.text.length()/(segments[0].text.length()+lastSent.text.length()) * (segments[0].stopTime - segments[0].startTime)+segments[0].startTime;
            lastSent.startTime = segments[segments.size()-2].stopTime;




        }else {
	  cout << "SEG KEEP All" << endl;
            lastSent.text = segments[0].text;
            segments.erase(segments.begin());
        }


    }
    

    cout << "SEG: Old last segment:" << segments.back().text << endl;

        cout << "Last word Punc new:" << lastWordPunc << endl;
    segments.back().text = lastSent.text + " " + removePunc(segments.back().text);

    cout << "SEG: New last segment:" << segments.back().text << endl;


    service->process(&(segments.back()));


    segments.back().text = recase(segments.back().text);


    if(segments.back().text.compare("") == 0) {
        segments.erase(segments.begin()+segments.size());
    }else {
        if(lastSent.text.compare("") != 0) {
            segments.back().startTime = lastSent.startTime;
        }
    }


    for(int i = 0; i < segments.size(); i++) {
        cout << i << "th segment(" << segments[i].type <<"):" << segments[i].startTime << " - " << segments[i].stopTime << " :" << segments[i].text << endl;
    }


}

void WordDataFlow::markFinal() {
    Segment in = preInput;
    cout << "Resegment: " << in.startTime << " " << in.stopTime << " " << in.text  << endl;
    string result;
    string word;
    int duration = in.stopTime - in.startTime;
    stringstream s (stringstream::in | stringstream::out);
    s << in.text;
    s << " ";
    vector<string> words;

    if(currentSent.text.compare("") == 0) {
        currentSent.startTime = in.startTime;
    }
    while(!s.eof()) {
        s >> word;
        if(!s.eof()) {
            words.push_back(word);
        }
    }
    for(int i = 0; i < words.size(); i++) {
        if(puncChars.find(words[i]) == puncChars.end()) {
            string last = words[i].substr(words[i].size()-1,1);
            while(puncChars.find(last) != puncChars.end()) {
                words[i] = words[i].substr(0, words[i].size()-1);
                last = words[i].substr(words[i].size()-1,1);
            }
            word = words[i];
            currentSent.text.append(" ");
            currentSent.text.append(word);
        //currentSentWordCount ++;
        }
    }
    currentSent.stopTime = in.stopTime;
    cout << "New stop time 3:" << currentSent.startTime << " " << currentSent.stopTime << "for:" << currentSent.text << endl;

    preInput.text = "";
    preInput.startTime = preInput.stopTime;
}




bool WordDataFlow::checkNewData() {
    cout << "Last stop time:" << lastStopTime << "Pre input stop time" << preInput.stopTime << endl;
    return preInput.stopTime > lastStopTime;
}


void WordDataFlow::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "maxContext") == 0) {
            maxContext = atoi(node->value());
        }else if (strcmp(node->name(), "paragraphSize") == 0) {
            paragraphSize = atoi(node->value());
        }
    }

}
string WordDataFlow::removePunc(const string in) {
    string word;
    stringstream s (stringstream::in | stringstream::out);
    s << in;
    s << " ";
    string words;

    while(!s.eof()) {
        s >> word;
        if(!s.eof()) {
            if(puncChars.find(word) == puncChars.end()) {
                string last = word.substr(word.size()-1,1);
                while(puncChars.find(last) != puncChars.end()) {
                    word = word.substr(0, word.size()-1);
                    last = word.substr(word.size()-1,1);
                }

                words += word+ " ";
            }
        }
    }

    return words;

}

string WordDataFlow::recase(const string in) {


    stringstream s (stringstream::in | stringstream::out);
    s << in;
    s << " ";
    string word;
    string words;
    bool localLastWordPunc = lastWordPunc;
    while(!s.eof()) {
        s >> word;

        if(!s.eof()) {
            if(localLastWordPunc) {
		cout << "Recase here 2:" << word[0] << endl;		    
                word[0] = std::toupper( word[0] );
		cout << "Recase here 2:" << word[0] << endl;		    
            }
            words += word+ " ";
            string last = word.substr(word.length()-1,1);
            if(puncChars.find(word) != puncChars.end() || puncChars.find(last) != puncChars.end()) {
                if(strcmp(last.c_str(),",") != 0) {
                    localLastWordPunc = true;
                }else{
                    localLastWordPunc = false;
                }

            }else {
                localLastWordPunc = false;
            }
        }
    }
    return words;
}
