#!/usr/bin/env python

import os
import re

Exp = re.compile('root[ ]+(\d+)')


PsStr = "ps -ef|grep erlang |grep %sline@"%('')


Buf = os.popen(PsStr).read()
Lines = Buf.split('\n')
for L in Lines:
    if L.find('ps -ef|grep erlang') == -1:
        Res = Exp.findall(L)
        if len(Res) > 0:
            os.system('kill %d' % int(Res[0]))
