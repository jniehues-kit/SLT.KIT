#ifndef SEGMENT_H_
#define SEGMENT_H_


#include <string>
#include <cstdlib>
#include <util.h>
#include <vector>
using namespace std;

#define FINAL 0
#define PREL_FULL_SENTENCE 1
#define PREL_PART_SENTENCE 2

#define TRACEPRINT(L) if(traceLevel() > L)


class Segment {

public:
    Segment() {translationDetails = 0; text = ""; lattice = "";type = FINAL;startTime = 0;stopTime = 0;};
    int translationDetails;
    string text;
    string lattice;
    string originalInput;
    string prevPunc; 
    int type;
    int startTime;
    int stopTime;
    int target_length;

};

typedef vector<Segment> Text;


#endif
