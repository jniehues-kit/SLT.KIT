#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys


sentenceEnd=[".","!","?"]

def add(s_filename,t_filename,context):

    s_f = open(s_filename)
    t_f = open(t_filename)

    s = s_f.readline()
    t = t_f.readline()

    stat = [({},{}) for i in range(context)]
    
    while(s and t):
        w_s = s.strip().split();

        w_t = t.strip().split();

        for i in range(min(context,len(w_t))):
            if(w_t[i][0] in stat[i][0]):
                stat[i][0][w_t[i][0]] += 1;
            else:
                stat[i][0][w_t[i][0]] = 1
            if(len(w_t[i]) > 1):
                if(w_t[i][1:] in stat[i][1]):
                    stat[i][1][w_t[i][1:]] += 1;
                else:
                    stat[i][1][w_t[i][1:]] = 1
            else:
                if(w_t[i][1:] in stat[i][1]):
                    stat[i][1][""] += 1;
                else:
                    stat[i][1][""] = 1

        if(not 'L' in stat[0][0]):
            print w_s[0].title(),
        elif(not 'U' in stat[0][0] or stat[0][0]['L'] > stat[0][0]['U']):
            print w_s[0],
        else:
            print w_s[0].title(),

        maxPunc = ""
        maxCount = 0
        for k in stat[0][1].keys():
            if(stat[0][1][k] > maxCount):
                maxPunc=k
                maxCount = stat[0][1][k]
        #print stat[0],maxPunc
        if(maxPunc != ""):
            print maxPunc,
        if any(p in maxPunc for p in sentenceEnd):
            print "";

        s = s_f.readline()
        t = t_f.readline()
        stat = stat[1:]+[({},{})]        
            


def main():
    args=sys.argv[1:];
    if(len(args) == 3):
        add(args[0],args[1],int(args[2]));
    else:
        raise SystemExit("Usage: python "+sys.argv[0]+" source U/LFile context")


main();
