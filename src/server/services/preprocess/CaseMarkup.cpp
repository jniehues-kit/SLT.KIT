
#include "CaseMarkup.h"

#ifdef MONGODB

CaseMarkup::CaseMarkup(xml_node<> * desc,Service * p) : Service(desc,p),last_date(std::chrono::milliseconds(0)),current_date(std::chrono::milliseconds(0)),loc("en_US.UTF-8") {
#else
  CaseMarkup::CaseMarkup(xml_node<> * desc,Service * p) : Service(desc,p),loc("en_US.UTF-8") {
#endif


#ifdef MONGODB
  mdb_address="mongodb://mtasr:!-mDB4All-!@i13pc201.ira.uka.de:27017";
  dynamicUpdate = false;
#endif


    mflist = ""; 
    postCommand = "";
  
    use_previous_punc = false;
    ignore_punc_len = 2; 

    parseXML(desc);
    loadMFcase();

#ifdef MONGODB
    if(dynamicUpdate) {
      sourcePrepro = ServiceFactory::createService(sourcePreproFile.c_str());
    }

#endif

    if(postCommand.compare("") != 0) {
      
      postStream.open( postCommand.c_str(), std::ios_base::out | std::ios_base::in );

    }


}


CaseMarkup::~CaseMarkup() {
}


void CaseMarkup::parseXML(xml_node<> * desc) {

 for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "use_previous_punc") == 0) {
            use_previous_punc = atoi((trim(node->value())).c_str());
            cout << "use_previous_punc" << use_previous_punc << endl; 
	}else if (strcmp(node->name(), "ignore_punc_len") == 0) {
            ignore_punc_len = atoi((trim(node->value())).c_str());
            cout << "ignore_punc_len" << ignore_punc_len << endl;
        }else if (strcmp(node->name(), "mflist") == 0){ 
	    mflist = trim(node->value()); 
        }else if (strcmp(node->name(), "postprocess") == 0) {
            postCommand = trim(node->value());
#ifdef MONGODB
	}else if (strcmp(node->name(), "dynamicUpdate") == 0) {
	  dynamicUpdate = stoi(node->value()) == 1;
	}else if (strcmp(node->name(), "sourcePrepro") == 0) {
	  sourcePreproFile = trim(node->value());
	}else if (strcmp(node->name(), "mongodb") == 0) {
	  mdb_address = trim(node->value());
#endif
        }
    }

}

void CaseMarkup::preprocess(Segment * seg) {


	TRACEPRINT(2) cout << "Input to Case Markup" << seg->text << endl;
	boost::regex e("([[:alpha:]])(\\.)"); 
        string r = "$1 $2"; 
        seg->text = boost::regex_replace(seg->text, e, r,boost::match_default | boost::format_all);
        boost::regex plussign("([[:alpha:]]) (\\+) ([[:alpha:]])"); 
        string replace_plus = "$1$2$3"; 
        seg->text = boost::regex_replace(seg->text, plussign, replace_plus,boost::match_default | boost::format_all); 
        boost::regex minussign("([[:alpha:]]) (\-) ([[:alpha:]])");
        string replace_minus = "$1$2$3";
        seg->text = boost::regex_replace(seg->text, minussign, replace_minus,boost::match_default | boost::format_all);
	
        //seg->text =  regex_replace (seg->text, e, r);
        TRACEPRINT(2) cout << "Input to Case Markup - regex:" << seg->text << endl;
        
	if(seg->text.compare("") != 0) {

	        stringstream s(seg->text);
		string word;
                string noPuncSent = "";
                int word_count = 0;        
	
                if (use_previous_punc > 0 ){
	           string prevDecision = ""; 
	           while (s >> word){
                     int punc = 0;
		     wstring wword = boost::locale::conv::utf_to_utf<wchar_t>(word);
		     for (std::wstring::iterator it=wword.begin(); it!=wword.end(); ++it) {
		       if (std::isalnum(*it,loc)) {
                            punc = 1;
                            break;
		       }

		     }

                     if (punc == 0) { // if the token is .,!? whatever
                        prevDecision = trim(prevDecision);
                        prevDecision = prevDecision + word + " ";
                     } else { // if it is alphanumeric 
                         prevDecision = prevDecision+ "0 ";
                        noPuncSent = noPuncSent + word + " ";
                        ++word_count;
                     }
                   }
                   prevDecision = trim(prevDecision); 
                   if (use_previous_punc == 2) { // remove last two tokens 
		        stringstream tempstr (prevDecision); 
 			vector<string> words_punc;
                        string tstr;  
                        while (tempstr >> tstr) { 
			    words_punc.push_back(tstr); 
		        }
                        string tempDecision = ""; 
                        if (words_punc.size() > ignore_punc_len ) {
			    for (int i = 0; i < words_punc.size() - ignore_punc_len ; i++){ 
	                        tempDecision = tempDecision + " " +words_punc[i]; 
                            }
		 	    for (int i = 0; i < ignore_punc_len; i++){ 
                                tempDecision = tempDecision + " 0";
                            }  
	                } else {
                            for (int i = words_punc.size(); i > 0; i--){ 
	                        tempDecision = tempDecision + "0 "; 
	                    }
			}
                        prevDecision = trim(tempDecision); 
                        cout << "previous_punc_2 after: " << prevDecision << endl; 
                   } 
                   seg->prevPunc = prevDecision;
                   cout << "previous punc: " << seg->prevPunc << endl;
                } else { 
                   cout << "no use previous punc" << endl; 
                   while (s >> word){
                     int punc = 0;
		     wstring wword = boost::locale::conv::utf_to_utf<wchar_t>(word);
		     for (std::wstring::iterator it=wword.begin(); it!=wword.end(); ++it) {
		       if (std::isalnum(*it,loc)) {
                            punc = 1;
                            break;
		       }

		     }

                     if (punc == 1){ // if word is alphanumeric only 
                        noPuncSent = noPuncSent + word + " ";
                        ++word_count;
                     }
                   }
                }
                noPuncSent = trim(noPuncSent); 
                seg->target_length = word_count; 
		seg->originalInput = noPuncSent;             
                seg->text = noPuncSent;  
                cout << "Case Markup puncUndo: " << seg->originalInput << endl;  
                cout << "fixed length: " << seg->target_length << endl;  
	}

	TRACEPRINT(2) cout << "Output to STTK" << seg->text << endl;

}
void CaseMarkup::postprocess(Segment * seg) {

	TRACEPRINT(2) cout << "Postprocess Case Markup" << seg->text << endl; 
	
        stringstream s(seg->originalInput);
        stringstream t(seg->text);
        string tag;
        string word;
        string update = ""; 
        int full_stop = 0; 

	if (use_previous_punc > 0){ 
           stringstream p(seg->prevPunc);  
           cout << "prev Punc stream " << seg->prevPunc << endl; 
           string prev; 
           while (t >> tag && s >> word && p >> prev){
              if ( (word.find("+") != string::npos) || (word.find("-") != string::npos) || (word.find("(") != string::npos)) { 
         	 
              } else if (full_stop == 1) { 
	          word[0] = toupper(word[0]);
              } else if (tag.find("U")!=string::npos) { 
	          if (caseSet.find(word) != caseSet.end()) {
                      word = caseSet[word]; 
                  } else { 
	              word[0] = toupper(word[0]);
                  } 
              }
              update = update+" "+ word;
              // punc control 
              if (tag.length() > 1) {
                 tag.erase(0, 1);
                 if ((tag.find(".") != string::npos) || (tag.find("?") != string::npos) || (tag.find("!") != string::npos)) { 
	            full_stop = 1; 
                 } else { 
                    full_stop = 0; 
		 }
                 update = update+tag;
              } else if ( prev.length() > 1) {
                 prev.erase(0, 1);
                 if ((prev.find(".") != string::npos) || (prev.find("?") != string::npos) || (prev.find("!") != string::npos)) {
                    full_stop = 1;
                 } else { 
		    full_stop = 0; 
		 } 
                 update = update+prev;
              } else { 
	         full_stop = 0; 
              }
           }
        } else { 
           while (t >> tag && s >> word ){
              if ( (word.find("+") != string::npos) || (word.find("-") != string::npos) || (word.find("(") != string::npos)) {

              } else if (full_stop == 1) { 
	         word[0] = toupper(word[0]); 
              }  else if (tag.find("U")!=string::npos) { 
                  if (caseSet.find(word) != caseSet.end()) {
                      word = caseSet[word];
                  } else {
                      word[0] = toupper(word[0]);
                  }
              }
              
              update = update+" "+ word;
              // punc control 
              if (tag.length() > 1) {
                 tag.erase(0, 1);
                 if ((tag.find(".") != string::npos) || (tag.find("?") != string::npos) || (tag.find("!") != string::npos)) { 
                    full_stop = 1; 
                 } else { 
		    full_stop = 0;
	         }
                 update = update+tag;
              } else { 
		 full_stop = 0; 
              }
           }
        }
        seg->text = update; 

	if(postCommand.compare("") != 0) {
	  postStream << seg->text  << "\n";
	  postStream.flush();
	  getline(postStream,seg->text);
	}


        TRACEPRINT(2) cout << "Output Postprocess Case Markup" << seg->text << endl; 
	//go though seg->text UL ,
	//replace with orignial words from seg->orignialInput

}

void CaseMarkup::update() {

  cout << "Update" << endl;
#ifdef MONGODB
  if(!dynamicUpdate) {
    return;
  }
  cout << "Update Casemarkup" << endl;
  getNamesFromDB();
  getPhrasesFromDB();
  last_date = current_date;
  cout << "Update Casemarkup done" << endl;
#endif

}


#ifdef MONGODB

void CaseMarkup::getNamesFromDB() {
  try {
    mongocxx::client conn{mongocxx::uri(mdb_address+"/LT")};
    
    auto collection = conn["LT"]["names"];
  
  
    auto cursor = collection.find(
				  bsoncxx::builder::stream::document{} << 
				  "date" << bsoncxx::builder::stream::open_document <<
				  "$gt" << last_date
				  << bsoncxx::builder::stream::close_document << 
				  bsoncxx::builder::stream::finalize);

    
    for (auto&& doc : cursor) {
      bsoncxx::document::element element = doc["name"];
      std::string name = element.get_utf8().value.to_string();      
      element = doc["date"];
      bsoncxx::types::b_date date = element.get_date();

      if(current_date < date) {
	current_date = date;
      }
      checkPhrase(name);
    }
  }catch(mongocxx::exception e) {
    cerr << "Mongo DB exception: " << e.what() << endl;
  }


}

void CaseMarkup::getPhrasesFromDB() {
  try {
    mongocxx::client conn{mongocxx::uri(mdb_address+"/LT")};
    
    mongocxx::database db = conn["LT"];
    auto cursor1 = db.list_collections();
    string start = getSourceLanguage()+"_";
    for (const bsoncxx::document::view& doc :cursor1)
      {
	bsoncxx::document::element ele = doc["name"];
	std::string name = ele.get_utf8().value.to_string();
	if(strncmp(name.c_str(), start.c_str(), start.size()) == 0) {
	  std::cout <<"Collection name:" << name << std::endl;


	  auto collection = conn["LT"][name];
  
  
	  auto cursor = collection.find(
					bsoncxx::builder::stream::document{} << 
					"date" << bsoncxx::builder::stream::open_document <<
					"$gt" << last_date
					<< bsoncxx::builder::stream::close_document << 
					bsoncxx::builder::stream::finalize);
	  
    
	  for (auto&& doc : cursor) {
	    bsoncxx::document::element element = doc["source"];
	    std::string source = element.get_utf8().value.to_string();      
	    element = doc["target"];
	    std::string target = element.get_utf8().value.to_string();      
	    element = doc["date"];
	    bsoncxx::types::b_date date = element.get_date();

	    if(current_date < date) {
	      current_date = date;
	    }
	    checkPhrase(source);
	    
	  }
	  
	}
	
      }
    
  }catch(mongocxx::exception e) {
    cerr << "Mongo DB exception: " << e.what() << endl;
  }


}


void CaseMarkup::checkPhrase(string & input) {


  Segment in;
  in.text = input;
  sourcePrepro->processForward(&in);
    

    string word;
    stringstream s (stringstream::in | stringstream::out);
    s << in.text;
    s << " ";
    while(!s.eof()) {
      s >> word;
      string copy = string(word);
      for(int i = 1; i < copy.length(); i++) {
	copy[i] = tolower(copy[i]);
      }
      
      if(word.compare(copy) != 0) {
	copy[0] = tolower(copy[0]);
	caseSet.insert(make_pair(copy, word));
      }
    }

}


#endif



void CaseMarkup::insertCasemap(string input){
        string origword;
        string caseword;
        string moresplit;

        stringstream s (stringstream::in | stringstream::out);
        s << input;
        s >> origword;
        s >> caseword;

        while (!s.eof()){
             s >> moresplit;
             caseword.append(" ");
             caseword.append(moresplit);
        }

        caseSet.insert(make_pair(origword, caseword));
        //cout << origword << "." << splitword << "." << endl;
}


void CaseMarkup::loadMFcase() {
       ifstream input(mflist);
       string caseword;

       while (!input.eof()) {
                getline(input, caseword);
                insertCasemap(caseword);
       }
       input.close();
}

