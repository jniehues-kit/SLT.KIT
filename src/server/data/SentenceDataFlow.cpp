#include "SentenceDataFlow.h"


SentenceDataFlow::SentenceDataFlow(xml_node<> * desc) {

    maxCurrentSent = 0;

    currentSentWordCount = 0;

    lastStopTime = INT_MIN;

    punc.insert('.');
    punc.insert('!');
    punc.insert(';');
    punc.insert('?');

    noIntermediateOutput = 0;
    parseXML(desc);
    
}

void SentenceDataFlow::input(const Segment & in) {

    preInput = in;
    string::size_type Pos;
    string replace("...");
    while (string::npos != (Pos = preInput.text.find(replace))) {
        preInput.text.replace(Pos, replace.length(), "");
    }

}

void SentenceDataFlow::markFinal() {
    string result;
    string word;
    int duration = preInput.stopTime - preInput.startTime;
    stringstream s (stringstream::in | stringstream::out);
    s << preInput.text;
    s << " ";
    vector<string> words;

    if(currentSent.text.compare("") == 0) {
        currentSent.startTime = preInput.startTime;
    }
    while(!s.eof()) {
        s >> word;
        if(!s.eof()) {
            words.push_back(word);
        }
    }
    for(int i = 0; i < words.size(); i++) {
        word = words[i];
        currentSent.text.append(" ");
        currentSent.text.append(word);
        currentSentWordCount ++;
        //          if(word[word.size()-1] == '.' || word[word.size()-1] == ',') {
        if(punc.find(word[word.size()-1]) != punc.end()) {
            currentSent.stopTime = 1.0*(i+1)/words.size() * duration + preInput.startTime;
            cout << "New stop time 4:" << currentSent.startTime << " " << currentSent.stopTime << endl;
            inputQueue.push(currentSent);
            currentSent.text = "";
            currentSent.startTime = currentSent.stopTime;
        currentSentWordCount = 0;
        }else if(word.substr(0,4).compare("<br>") == 0) {
            currentSent.stopTime = 1.0*(i+1)/words.size() * duration + preInput.startTime;
            cout << "New stop time 5:" << currentSent.startTime << " " << currentSent.stopTime << endl;
            inputQueue.push(currentSent);
            currentSent.text = "";
            currentSent.startTime = currentSent.stopTime;
            currentSentWordCount = 0;
        }else if(word.size() > 4 && word.substr(word.size()-4).compare("<br>") == 0) {
            currentSent.stopTime = 1.0*(i+1)/words.size() * duration + preInput.startTime;
            cout << "New stop time 6:" << currentSent.startTime << " " << currentSent.stopTime << endl;
            inputQueue.push(currentSent);
            currentSent.text = "";
            currentSent.startTime = currentSent.stopTime;
            currentSentWordCount = 0;
        }
    }
    currentSent.stopTime = preInput.stopTime;

    preInput.text = "";
    preInput.startTime = preInput.stopTime;
}

void SentenceDataFlow::clear() {
    inputQueue = queue<Segment>();
    currentSent.text = "";
    currentSent.stopTime = 0;
    currentSent.startTime = 0;
    currentSentWordCount = 0;
    preInput.text = "";
    preInput.stopTime = 0;
    preInput.startTime = 0;
    lastStopTime = INT_MIN;
    cout << "Clear input" << endl;
}

Text SentenceDataFlow::getData() {


    vector<Segment> result;

    if(!checkNewData()) {
        return result;
    }

    while(inputQueue.size()> 0) {
        Segment translation;

        Segment in = inputQueue.front();
        inputQueue.pop();

        translation.text = in.text;
        translation.startTime= in.startTime;
        translation.stopTime = in.stopTime;
        result.push_back(translation);
    }

    getPreData(result);

    if(result[result.size() -1].type != FINAL) {
        int startTime;
        int stopTime;
        if(currentSent.text.compare("") == 0) {
            startTime = preInput.startTime;
        }else {
            startTime = currentSent.startTime;
        }

        if(preInput.text.compare("") == 0) {
            stopTime = currentSent.stopTime;
        }else {
            stopTime = preInput.stopTime;
        }
        result[result.size() -1].startTime = startTime;
        result[result.size() -1].stopTime = stopTime;

    }

    lastStopTime = preInput.stopTime;
    return result;
}

void SentenceDataFlow::getPreData(Text & result) {

    string word;
    stringstream s (stringstream::in | stringstream::out);
    s << currentSent.text + " " + preInput.text;
    s << " ";
    vector<string> words;
    string tempSent = "";
    while(!s.eof()) {
        s >> word;
        if(!s.eof()) {
            words.push_back(word);
        }
    }
    for(int i = 0; i < words.size(); i++) {
        word = words[i];
        tempSent.append(" ");
        tempSent.append(word);
        if(punc.find(word[word.size()-1]) != punc.end()) {
            Segment hyp;
            hyp.text = tempSent;
            hyp.type = PREL_FULL_SENTENCE;
            result.push_back(hyp);
            tempSent = "";
        }else if(word.substr(0,4).compare("<br>") == 0) {
            Segment hyp;
            hyp.text = tempSent;
            hyp.type = PREL_FULL_SENTENCE;
            result.push_back(hyp);
            tempSent = "";
        }

    }
    cout << "Partial sentence:" << tempSent << endl;
    if(tempSent.compare("") != 0) {
        Segment hyp;
        hyp.text = tempSent;
        hyp.type = PREL_PART_SENTENCE;
        result.push_back(hyp);
    }
}


void SentenceDataFlow::process(vector<Segment> & segments,Service * service) {

  if(noIntermediateOutput == 1) {
      for(int i = segments.size()-1; i >= 0; i--) {
	if(segments[i].type != FINAL) {
	  segments.erase(segments.begin()+i);
	}
      }
  }

  for(int i = 0; i < segments.size(); i++) {
        service->process(&segments[i]);
        cout << i << "th segment (" << segments[i].type <<"):" << segments[i].startTime << " - " << segments[i].stopTime << " :" << segments[i].text << endl;
    }

    //merge non-final segments
    if(segments.size() > 1 && segments[segments.size() - 2].type != FINAL) {
        int i = segments.size() -2;
        while(i >= 0 && segments[i].type != FINAL) {
            segments[segments.size() -1 ].text = segments[i].text + " " + segments[segments.size() -1 ].text;
            segments.erase(segments.begin()+i);
            i--;
        }
    }

    for(int i = 0; i < segments.size(); i++) {
	    while( i < segments.size() && segments[i].text.compare("") == 0) {
		    segments.erase(segments.begin()+i);
	    }
	    if(i < segments.size()) {
		    cout << i << "th merged segment(" << segments[i].type <<"):" << segments[i].startTime << " - " << segments[i].stopTime << " :" << segments[i].text << endl;
	    }
    }


}


bool SentenceDataFlow::checkNewData() {
    return preInput.stopTime > lastStopTime;
}

void SentenceDataFlow::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "noIntermediateOutput") == 0) {
            noIntermediateOutput = atoi(node->value());
        }
    }

}
