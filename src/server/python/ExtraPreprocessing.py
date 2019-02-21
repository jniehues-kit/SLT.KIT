# -*- coding: utf-8 -*-
# vim: set encoding=utf-8:
import sys;
import re;
import os;

class ExtraPreprocessing():
    '''
    expands common English and German contractions
    splits off apostrophes
    '''
    umlaute = "áèìéíóúñüãõúäöüßÄÖÜéàèùâêîôûëïüÿçæœÉÀÈÙÂÊÎÔÛËÏÜŸÇÆŒó".decode("utf-8") #needed for proper word matching in regex
    prefixDir = os.path.dirname(os.path.abspath(__file__))
    prefixName = "nonbreaking_prefix"


    def __init__(self,language,tokenize,ignoreCase):
        #init variables
        self.lang = language
        self.splitPunc = tokenize
        self.lowercase = ignoreCase
        #print "ExtraPrep tokenize: " + str(tokenize)
        self.prefixes = []
        self.numberprefixes = []
        if(self.splitPunc):
            self.loadNonbreakingPrefixes()

    def expandEnglishContractions(self,line):
        #leave untreated: ain't
        line = re.sub(r"I'm", r"I am", line)
        line = re.sub(r"(You|We|They|you|we|they)\s*'re", r"\1 are", line)
        line = re.sub(r"(He|She|It|he|she|it)\s*'s", r"\1 is", line) #might also be "has"
        line = re.sub(r"(I|You|He|She|It|We|They|you|he|she|it|we|they)\s*'d", r"\1 would", line) #might also be "had"
        line = re.sub(r"(I|You|He|She|It|We|They|you|he|she|it|we|they)\s*'ll", r"\1 will", line) #might also be "shall"
        line = re.sub(r"(I|You|We|They|you|we|they)\s*'ve", r"\1 have", line)
        line = re.sub(r"(Let|let)\s*'s", r"\1 us", line)
        line = re.sub(r"(That|There|These|Those|What|Where|Why|Who|How|Here|Whom|that|there|these|those|what|where|why|who|how|here|whom)\s*'re", r"\1 are", line)
        line = re.sub(r"(This|That|There|What|Where|Why|Who|When|How|Here|Yet|this|that|there|what|where|why|who|when|how|here|yet)\s*'s", r"\1 is", line) #might also be "has"
        line = re.sub(r"(That|There|Who|that|there|who)\s*'d", r"\1 would", line) #might also be "had"
        line = re.sub(r"(What|Where|Why|When|How|what|where|why|when|how)\s*'d", r"\1 did", line) #might also be "would", "had"
        line = re.sub(r"(This|That|There|What|Who|How|this|that|there|what|who|how)\s*'ll", r"\1 will", line) #might also be "shall"
        line = re.sub(r"(That|There|These|Those|Which|What|Where|Who|How|Must|Might|Could|Should|Would|May|that|there|these|those|which|what|where|who|how|must|might|could|should|would|may)\s*'ve", r"\1 have", line)
        line = re.sub(r"(Do|Does|Did|Are|Were|Is|Was|Can|Have|Had|Has|Must|Might|Could|Should|Would|Need|do|does|did|are|were|is|was|can|have|had|has|must|might|could|should|would|need)n\s*'t", r"\1 not", line)
        line = re.sub(r"(W|w)on\s*'t", r"\1ill not", line)
        line = re.sub(r"(All|Something|Nothing|all|something|nothing)\s*'s", r"\1 is", line)
        return line

    def expandGermanContractions(self,line):
        line = re.sub(r" '(n|ne|nen|nem|ner)", r" ei\1", line)
        line = re.sub(r" 's", r" es", line)
        line = re.sub(r"(bau|bekomm|brauch|brech|denk|erzähl|fang|find|geb|geh|glaub|grad|hab|hatt|hätt|hoff|komm|könnt|mach|möcht|müsst|nehm|sag|schreib|solang|tu|verlänger|wär|werd|würd|zeig)' ", r"\1e ", line)
        line = re.sub(r"(bin|bleibt|braucht|bringt|damit|darf|der|die|dir|du|er|fand|fänd|funktioniert|gab|gäb|gefällt|geht|gibt|ging|haben|hat|heißt|heisst|hilft|ich|ihr|interessiert|ist|kann|klappt|kommt|liegt|macht|mag|man|mir|mögen|nimm|ob|passt|probier|reicht|schau|schaut|scheint|sei|sich|sie|sieht|sind|soll|steht|stimmt|trifft|tut|um|war|weil|wen|wenn|wer|werd|wie|will|wir|wird|wo|worum|wundert|würd)'s", r"\1 es", line)
        line = re.sub(r"(find|glaub|hab|mach|sag|schreib|tu|versteh|versuch|wär)'s", r"\1e es", line)
        return line

    def splitOffPunc(self, line):
        #split off any special character not explicitly dealt with
        line = re.sub(r"([^\w\s\.,\-'\/"+self.umlaute+"<>])", r" \1 ", line)

        #split off colon, except when preceded by another colon or nonbreaking prefix
        line = re.sub(r"([\w"+self.umlaute+"'-\.]+|^)\.($|\s|[\w"+self.umlaute+"'-<]+)", self.splitColon, line)

        #split off comma except within numbers, eg. 5,300
        line = re.sub(r"([^0-9]),([^0-9])", r"\1 , \2", line)
        line = re.sub(r"([0-9]),([^0-9])", r"\1 , \2", line)
        line = re.sub(r"([^0-9]),([0-9])", r"\1 , \2", line)

        return line

    def splitColon(self, matchObj):
        if matchObj.group(1).isdigit() and  matchObj.group(2).isdigit():
            return matchObj.group()
        if matchObj.group(1) in self.numberprefixes:
            if matchObj.group(2).isdigit():
                return matchObj.group()
            else:
                return matchObj.group(1) + " . " + matchObj.group(2)
        elif matchObj.group(1) in self.prefixes:
            return matchObj.group()
        else:
            return matchObj.group(1) + " . " + matchObj.group(2)

    def splitRight(self, matchObj):
        if (matchObj.group(1).isalpha() and matchObj.group(2).isalpha()) or (matchObj.group(1).isdigit() and matchObj.group(2) == "s"):
            return matchObj.group(1) + " '" + matchObj.group(2)
        else:
            return matchObj.group(1) + " ' " + matchObj.group(2)

    def splitLeft(self, matchObj):
        #if matchObj.group(1).isalpha() and matchObj.group(2).isalpha():
        #    return matchObj.group(1) + "' " + matchObj.group(2)
        if matchObj.group(1).isalpha():
            return matchObj.group(1) + "' " + matchObj.group(2)
        else:
            return matchObj.group(1) + " ' " + matchObj.group(2)

    def replaceDots(self, matchObj):
        c = len(matchObj.group())
        return " "+"DOT"*c+"MULTI "

    def replaceMultidot(self, matchObj):
        c = matchObj.group().count("DOT")
        return "."*c

    def loadNonbreakingPrefixes(self):
        if(self.lang == "english"):
            prefixFile = os.path.join(self.prefixDir, self.prefixName + ".en")
        elif(self.lang == "german"):
            prefixFile = os.path.join(self.prefixDir, self.prefixName + ".de")
        elif(self.lang == "french"):
            prefixFile = os.path.join(self.prefixDir, self.prefixName + ".fr")
        elif(self.lang == "spanish"):
            prefixFile = os.path.join(self.prefixDir, self.prefixName + ".es")
        elif(self.lang == "italian"):
            prefixFile = os.path.join(self.prefixDir, self.prefixName + ".it")
        elif(self.lang == "portuguese"):
            prefixFile = os.path.join(self.prefixDir, self.prefixName + ".pt")
        else:
            raise ValueError("Could not find nonbreaking_prefix file for %r" % self.lang)

        with open(prefixFile, 'r') as f:
            #print "loading nonbreaking prefixes from "+prefixFile+" for lang "+self.lang
            for line in f:
                line = line.strip()
                #ignore comments and empty lines
                if len(line) == 0 or line[0] == '#':
                    pass
                else:
                    if line.endswith("#NUMERIC_ONLY#"):
                        self.numberprefixes.append(line.split()[0])
                    else:
                        self.prefixes.append(line)

    def lowercaseWords(self,line):
        words = line.split()
        for i in range(0, len(words)):
            if(len(words[i])>1 and words[i].isupper()): #don't lowercase acronyms, except for single letters
                pass
            else:
                words[i] = words[i][0].lower()+words[i][1:]
        line = " ".join(words)
        return line

    def process(self,line):
        line = line.decode("utf-8")
        p = re.compile(r'@[A-Z]*\s*\{[^\}]*\}')
        start = 0
        result = ""
        for m in p.finditer(line):
            if(m.start() > 0):
                result += self.processPart(line[start:m.start()-1])+" "
            result += m.group()
            start = m.span()[1]
        result += self.processPart(line[start:])
        return result.encode("utf-8")
    def processPart(self,line):
        # turn ` into '
        line = re.sub(r"`", r"'", line)
        #turn '' into "
        line = re.sub(r"''", r'"', line)
        #replace multiple periods
        line = re.sub(r"(\.\.+)", self.replaceDots, line)
        if(self.lang == "english"):
            line = self.expandEnglishContractions(line)
        elif(self.lang == "german"):
            line = self.expandGermanContractions(line)
        #split off remaining apostrophes by whitespace
        #split right for english and german
	if(self.lang == "english" or self.lang == "german"):
            line = re.sub(r"([^\s])'([^\s])", self.splitRight, line)
        elif(self.lang == "french" or self.lang == "spanish" or self.lang == "italian" or self.lang == "portuguese"):
            line = re.sub(r"([^\s])'([^\s])", self.splitLeft, line)
        else:
            line = re.sub(r"'", r" ' ", line)
        #split off other punctuation if tokenization is turned on
        if(self.splitPunc):
            line = self.splitOffPunc(line)
        #replace multidots placeholder
        line = re.sub(r"((DOT)+MULTI)", self.replaceMultidot, line)
        if(self.lowercase):
            line = self.lowercaseWords(line)
        #remove extra whitespace
        line = re.sub(r" +", r" ", line)
        line = re.sub(r" $", r"", line)
        return line
