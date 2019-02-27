#!/usr/bin/env python
# -*- coding: utf-8 -*-


import codecs

from apply_bpe import BPE


class BPEService(object):

    def __init__(self,codes):
        self.bpe = BPE(codecs.open(codes,encoding='utf-8'))

    def process_line(self,line):
        return self.bpe.process_line(line.decode("UTF-8")).encode("UTF-8")
