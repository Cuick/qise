#!/usr/bin/env python
import os
import sys
import re
import time

NODES = {
    "timer": {"ip": "127.0.0.1", "dbdir": None, "smp": True, "addtion": None},
    "db": {"ip": "127.0.0.1", "dbdir": "../dbfile", "smp": True, "addtion": None},
    "line": {"ip": "127.0.0.1", "dbdir": None, "smp": True, "addtion": None},
    "chat1": {"ip": "127.0.0.1", "dbdir": None, "smp": False, "addtion": None},
    "guild": {"ip": "127.0.0.1", "dbdir": None, "smp": True, "addtion": None},
    "auth": {"ip": "127.0.0.1", "dbdir": None, "smp": True, "addtion": None},
    "gm": {"ip": "127.0.0.1", "dbdir": None, "smp": False, "addtion": None},
    "map1": {"ip": "127.0.0.1", "dbdir": None, "smp": False, "addtion": None},
    "map2": {"ip": "127.0.0.1", "dbdir": None, "smp": False, "addtion": None},
    "map3": {"ip": "127.0.0.1", "dbdir": None, "smp": False, "addtion": None},
    "map4": {"ip": "127.0.0.1", "dbdir": None, "smp": False, "addtion": None},
    "gate1": {"ip": "127.0.0.1", "dbdir": None, "smp": False, "addtion": None},
    "gate2": {"ip": "127.0.0.1", "dbdir": None, "smp": False, "addtion": None},
    "api": {"ip": "127.0.0.1", "dbdir": None, "smp": False, "addtion": None},

}


def get_line_node():
    return "line@" + NODES["line"]["ip"]

def get_local_ips():
    if sys.platform=='linux2':
        child = os.popen("/sbin/ifconfig | grep 'inet addr' | awk '{print $2}'")
        current_ip = child.read()
        current_ip = current_ip.split('\n')
        current_ips = []
        for i in current_ip:
            if i !='':
                current_ips.append(i.replace('addr:',''))
    else:
        child = os.popen("ipconfig")
        current_ip = child.read()
        current_ip = current_ip.split('\n')
        current_ips = []
        for i in current_ip:
            if i !='':
                if (i.find('IP')!=-1) and (i.find(' : ')!=-1):
                    indx = i.find(' : ')
                    current_ips.append(i[(indx + 3):])
    return current_ips

if __name__ == '__main__':
    os.chdir("../ebin")
    os.system("rm -rf Mnesia*")
    local_ips = ["127.0.0.1"]
    for sname in NODES:
        cmdline = "ulimit -SHn 65535 && erl -env ERL_MAX_ETS_TABLES 100000 +P 100000 +K true -detached"
        if NODES[sname]["ip"] in local_ips:
            if NODES[sname]["smp"]:
                cmdline += " -smp"
            if NODES[sname]["dbdir"]:
                cmdline += " -mnesia dir \'\"" + NODES[sname]["dbdir"] + "\"\'"
            cmdline += " -name " + sname + "@" + NODES[sname]["ip"]
            cmdline += " -s server_tool run --line " + get_line_node()
            cmdline += " > /dev/null 2>&1&"
            print cmdline
            os.system(cmdline)



