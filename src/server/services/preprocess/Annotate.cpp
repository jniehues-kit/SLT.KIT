#include "Annotate.h"
#ifdef LMDB

AnnotationDB::AnnotationDB(xml_node<> * desc,Service * p) : Service(desc,p) ,env(lmdb::env::create()),last_date(std::chrono::milliseconds(0)),current_date(std::chrono::milliseconds(0)) {

#ifdef MONGODB
  mdb_address="mongodb://mtasr:!-mDB4All-!@i13pc201.ira.uka.de:27017";
  dynamicUpdate = false;
#endif

    dbfile = "";

    multiWord = false;

    parseXML(desc);

    //env = lmdb::env::create();
    env.open(dbfile.c_str());

#ifdef MONGODB
    if(dynamicUpdate) {
      sourcePrepro = ServiceFactory::createService(sourcePreproFile.c_str());
      targetPrepro = ServiceFactory::createService(targetPreproFile.c_str());
      loadWordList();
    }

#endif
}

AnnotationDB::~AnnotationDB() {
}


void AnnotationDB::parseXML(xml_node<> * desc) {

    for (xml_node<> * node = desc->first_node(); node ; node = node->next_sibling()) {
        if (strcmp(node->name(), "filename") == 0) {
            dbfile = trim(node->value());
	}else if (strcmp(node->name(), "multiword") == 0) {
	  multiWord = stoi(node->value()) == 1;
	}else if (strcmp(node->name(), "dynamicUpdate") == 0) {
	  dynamicUpdate = stoi(node->value()) == 1;
	}else if (strcmp(node->name(), "sourcePrepro") == 0) {
	  sourcePreproFile = trim(node->value());
	}else if (strcmp(node->name(), "targetPrepro") == 0) {
	  targetPreproFile = trim(node->value());
	}else if (strcmp(node->name(), "wordList") == 0) {
	  wordListFile = trim(node->value());
#ifdef MONGODB
	}else if (strcmp(node->name(), "mongodb") == 0) {
	  mdb_address = trim(node->value());
#endif
        }
    }

}

void AnnotationDB::preprocess(Segment * seg) {

	TRACEPRINT(2) cout << "Input to Annotation DB" << seg->text << endl;

	if(seg->text.compare("") != 0) {
	  
	  if(multiWord) {
	    preprocessMultiWord(seg);
	  }else {
	    preprocessSingleWord(seg);
	  }


	}

	TRACEPRINT(2) cout << "Output from Annotation DB" << seg->text << endl;

}

void AnnotationDB::preprocessSingleWord(Segment * seg) {
  auto rtxn = lmdb::txn::begin(env, nullptr, MDB_RDONLY);
  auto dbi = lmdb::dbi::open(rtxn, nullptr);
  
  string input = seg->text;
  seg->text = "";
  string word;
  stringstream s (stringstream::in | stringstream::out);
  s << input;
  s << " ";
  while(!s.eof()) {
    s >> word;
    if(!s.eof()) {
      
      lmdb::val key{word.c_str()};
      lmdb::val value;
      
      bool found = lmdb::dbi_get(rtxn, dbi, key, value);
      if(found) {
	string res(value.data(),0,value.size());
	seg->text.append(" # "+word+" ## "+res+" #");
      }else {
	seg->text.append(" ");
	seg->text.append(word);    
      }
    }
  }

}


void AnnotationDB::loadWords(string & text,vector<string> & words) {
  stringstream s (stringstream::in | stringstream::out);
  s << text;
  s << " ";
 
  
  while(!s.eof()) {
    string word;
    s >> word;
    if(word.find_first_not_of(' ') != std::string::npos) {
      words.push_back(word);
    }
  }
}


void AnnotationDB::findPhrases(vector<string> & words,map<int,map<int,string> >& phrases) {
  auto rtxn = lmdb::txn::begin(env, nullptr, MDB_RDONLY);
  auto dbi = lmdb::dbi::open(rtxn, nullptr);

  bool usePhrase[words.size()+1];

  string nGram[words.size()];

  for(int i = 0; i < words.size(); i++) {
    nGram[i] = "";
    usePhrase[i] = true;
  }
  //special case for first iteration
  usePhrase[words.size()] = true;

  bool useLength = true;
  for(int length = 1; useLength && length <= words.size(); length ++) {
    useLength = false;
    for(int start = 0; start+length <= words.size(); start++) {
      if(usePhrase[start] or usePhrase[start+1]) {
	if(length == 1) {
	  nGram[start] = words[start];
	}else if(usePhrase[start]){
	  nGram[start] = nGram[start] + " "+words[start+length-1];
	}else {
	  nGram[start] = words[start] + " "+nGram[start+1];
	}

	lmdb::val key{nGram[start].c_str()};
	lmdb::val value;
	bool found = lmdb::dbi_get(rtxn, dbi, key, value);
	if(found) {
	  string res(value.data(),0,value.size());
	  useLength = true;
	  usePhrase[start] = true;
	  if(trim(res).compare("") != 0) {
	    if(phrases.find(length) != phrases.end()) {
	      phrases[length][start] = res;
	    }else{
	      map<int,string> s;
	      s[start] = res;
	      phrases[length] = s;
	    }
	  }
	}else {
	  usePhrase[start] = false;
	}
	
      }
    }

  }

}


void AnnotationDB::selectPhrases(int size, map<int,map<int,string> > & phrases,vector<pair<pair<int,int>,string> > & segmentation) {
  //select 

  bool annotated[size];
  for(int i = 0; i < size; i++) {
    annotated[i] = false;
  }

  for (auto iter = phrases.rbegin(); iter != phrases.rend(); ++iter) {
    for(auto i2 = iter->second.begin(); i2 != iter->second.end(); i2++) {
      bool used = false;
      for(int i = 0; !used && i < iter->first; i++) {
	used = used || annotated[i2->first+i]; 
      }
      if(!used) {
	segmentation.push_back(make_pair(make_pair(i2->first,iter->first+i2->first),i2->second));
	for(int i = i2->first; !used && i < iter->first+i2->first; i++) {
	  annotated[i] = true; 
	}
      }
    }

  }

}

void AnnotationDB::preprocessMultiWord(Segment * seg) {


  vector<string> words;
  map<int,map<int,string> > phrases;
  vector<pair<pair<int,int>,string> > segmentation;

  loadWords(seg->text,words);

  findPhrases(words,phrases);

  selectPhrases(words.size(),phrases,segmentation);

  std::sort(segmentation.begin(),segmentation.end());

  //create annotated text
  int j = 0; //segment index
  int i = 0; // word index
  seg->text = "";
  while(i < words.size()) {

    if(j == segmentation.size()) {
      //all anotation done
      seg->text.append(" ");
      seg->text.append(words[i]);
      i++;
    }else if(i < segmentation[j].first.first ) {
      // no annotation for this word
      seg->text.append(" ");
      seg->text.append(words[i]);
      i++;
    }else{
      // annotate
      seg->text.append(" #");
      for(; i < segmentation[j].first.second; i++) {
	seg->text.append(" ");
	seg->text.append(words[i]);	
      }
      seg->text.append(" ## " + segmentation[j].second + " #");
      j++;
    }

  }

    
}


void AnnotationDB::postprocess(Segment * seg) {

}

void AnnotationDB::update() {

#ifdef MONGODB
  if(!dynamicUpdate) {
    return;
  }
  cout << "Update Annotation" << endl;
  vector<pair<string,string> >new_phrases;
  getNamesFromDB(new_phrases);
  getPhrasesFromDB(new_phrases);
  cout << "Number of new phrases:" << new_phrases.size() << endl;
  addNewPhrases(new_phrases);
  last_date = current_date;
  cout << "Update Annotation done" << endl;
#endif

}

#ifdef MONGODB

void AnnotationDB::addNewPhrases(vector<pair<string,string> > & phrases) {



  for(int i = 0; i < phrases.size(); i++) {
    Segment source;
    source.text = phrases[i].first;
    sourcePrepro->processForward(&source);
    Segment target;
    target.text = phrases[i].second;
    targetPrepro->processForward(&target);
    auto wtxn = lmdb::txn::begin(env);
    auto dbi = lmdb::dbi::open(wtxn, nullptr);
    dbi.put(wtxn, trim(source.text).c_str(),trim(target.text).c_str());
    wtxn.commit();
    insertPlaceholder(trim(source.text));
  }

}

void AnnotationDB::loadWordList() {

  ifstream input(wordListFile);
  string line;

  while (!input.eof()) {
    getline(input, line);
    line = trim(line);
    int space = line.find_first_of(SPACES);
    int count = atoi(line.substr(0,space).c_str());
    string word = trim(line.substr(space+1));
    wordList.insert(make_pair(word,count));
  }
  input.close();


}


void AnnotationDB::insertPlaceholder(string ngram) {

  string::size_type start = ngram.find_first_of(SPACES);
  string::size_type end = ngram.find_last_of(SPACES);
  if(start != string::npos) {

    string firstW = ngram.substr(0,start);
    string lastW = ngram.substr(end+1);
    
    string endNGram = ngram.substr(start+1);
    string startNGram = ngram.substr(0,end);

    auto rtxn = lmdb::txn::begin(env, nullptr, MDB_RDONLY);
    auto rdbi = lmdb::dbi::open(rtxn, nullptr);

      
    lmdb::val ekey{endNGram.c_str()};
    lmdb::val value;

    if(lmdb::dbi_get(rtxn,rdbi,ekey,value)) {

      rtxn.abort();
      insertPlaceholder(endNGram);
      return;

    }
    
    rtxn.abort();

    auto r2txn = lmdb::txn::begin(env, nullptr, MDB_RDONLY);
    auto r2dbi = lmdb::dbi::open(r2txn, nullptr);

    lmdb::val skey{startNGram.c_str()};

    if(lmdb::dbi_get(r2txn,r2dbi,ekey,value)) {

      r2txn.abort();
      insertPlaceholder(startNGram);
      return;

    }

    r2txn.abort();

    auto wtxn = lmdb::txn::begin(env);
    auto dbi = lmdb::dbi::open(wtxn, nullptr);
    if(wordList.find(firstW) != wordList.end()) {

      if(wordList.find(lastW) != wordList.end()) {

	if(wordList[firstW] > wordList[lastW]) {
	  dbi.put(wtxn,endNGram.c_str(),"");
	  wtxn.commit();
	  insertPlaceholder(endNGram);
	 
	}else {
	  dbi.put(wtxn,startNGram.c_str(),"");
	  wtxn.commit();
	  insertPlaceholder(startNGram);
	}


      }else {
	dbi.put(wtxn,endNGram.c_str(),"");
	wtxn.commit();
	insertPlaceholder(endNGram);
      }


    }else {
      dbi.put(wtxn,startNGram.c_str(),"");
      wtxn.commit();
      insertPlaceholder(startNGram);

    }

  }

}

void AnnotationDB::getNamesFromDB(vector<pair<string,string> > & phrases) {
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
      phrases.push_back(make_pair(name,name));

    }
  }catch(mongocxx::exception e) {
    cerr << "Mongo DB exception: " << e.what() << endl;
  }


}

void AnnotationDB::getPhrasesFromDB(vector<pair<string,string> > & phrases) {
  try {
    mongocxx::client conn{mongocxx::uri(mdb_address+"/LT")};
    
    auto collection = conn["LT"][getSourceLanguage()+"_"+getTargetLanguage()];
  
  
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
      phrases.push_back(make_pair(source,target));

    }
  }catch(mongocxx::exception e) {
    cerr << "Mongo DB exception: " << e.what() << endl;
  }


}

#endif

#endif
