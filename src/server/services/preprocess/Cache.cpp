#include "Cache.h"

Cache::Cache(xml_node<> * desc,Service * p) :Service(desc,p) {

    TRACEPRINT(1) cout << "Using Translation Cache" << endl;

    string br("<br><br>");

    TM.insert(make_pair(br,br));

}

Cache::~Cache() {


}

void Cache::clearService() {
    cache.clear();
}

void Cache::process(Segment * seg) {

    TRACEPRINT(2) cout << "Input to Cache " << seg->text << endl;

    string in = trim(seg->text);

    if(TM.find(in) != TM.end()) {
      TRACEPRINT(3) cout << "Using TM for: " << seg->text << endl; 
      seg->text = TM[in];

    }else if(seg->type == FINAL) {
        if(cache.find(seg->text) != cache.end()) {
            string input = seg->text;
            seg->text = cache[seg->text];
            cache.erase(input);
            TRACEPRINT(3) cout << "Use cache translation: " << input << endl;
        }else {
            child->process(seg);
        }


    }else if(seg->type == PREL_FULL_SENTENCE) {
        if(cache.find(seg->text) != cache.end()) {
            TRACEPRINT(3) cout << "Reuse translation: " << seg->text << endl;
            seg->text = cache[seg->text];
        }else {
            child->process(seg);
        }
    }else {
        child->process(seg);
    }



    TRACEPRINT(2) cout << "Output of Cache Postprocessing" << seg->text << endl;

}
