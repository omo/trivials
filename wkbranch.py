#!/usr/bin/env python
#  -*- coding: utf-8 -*-

import subprocess
import mechanize
import os
import pickle
import re
import glob
import sys
from optparse import OptionParser

CACHE_PATH = os.path.expanduser("~/.wkbranch.cache")

WORKDIRS = glob.glob(os.path.expanduser("~/work/webkit/*")) + map(lambda p: os.path.join(p, "src"), glob.glob(os.path.expanduser("~/work/chromium/*"))) 


def get_branch_output(dir=os.getcwd(), handle_stderr=None):
    return subprocess.Popen(["git", "branch"], stdout=subprocess.PIPE, stderr=handle_stderr, cwd=dir).stdout.read()

#print WORKDIRS
def branch_name_of(d):
    if not os.path.exists(d):
        return None
    outs = [o for o in get_branch_output(d, subprocess.PIPE).split("\n") if re.search("^\*", o)]
    if 0 < len(outs):
        return outs[0]
    else:
        None
        
def extract_bugid(line):
    m = re.search("(wk|cr)(\d+)", line)
    if not m:
        return None
    return (m.group(1), m.group(2))

def shorten(str):
    if 50 < len(str):
        return str[0:50] + "..."
    else:
        return str


class BugToTitle:

    @classmethod
    def open_cache(cls, path):
        if os.path.exists(path):
            return pickle.load(open(path))
        else:
            return {}
        
    def __init__(self, cache_path):
        self.cache_path = cache_path
        self.url_to_title = self.open_cache(cache_path)
        self.br = mechanize.Browser()
        self.br.set_handle_robots(False)

    def title_for(self, url):
        if self.url_to_title.get(url):
            return self.url_to_title.get(url)
        self.url_to_title[url] = self.fetch_title_for(url)
        self.save_cache()
        return self.url_to_title[url]

    def fetch_title_for(self, url):
        self.br.open(url)
        return self.br.title()

    def summary_for(self, type_and_bugid):
        if type_and_bugid[0] == "wk":
            title = self.title_for("http://bugs.webkit.org/show_bug.cgi?id=" + type_and_bugid[1])
            return title[title.find("–")+len("–"):]
        elif type_and_bugid[0] == "cr":
            title = self.title_for("http://code.google.com/p/chromium/issues/detail?id=" + type_and_bugid[1])
            return title[title.find("chromium -")+len("chromium -"):]
        else:
            return ""

    def save_cache(self):
        pickle.dump(self.url_to_title, open(self.cache_path, "w"))

    def decoreate_git_line(self, line):
        type_and_bugid = extract_bugid(line)
        if type_and_bugid:
            return " ".join([line, ":", shorten(self.summary_for(type_and_bugid))])
        else:
            return line
    
def workdir_branch_pair():
    ret = []
    for w in WORKDIRS:
        if os.path.isdir(w):
            name = branch_name_of(w)
            subname = branch_name_of(os.path.join(w, "third_party/WebKit"))
            if name:
                ret.append((w, name, subname))
    return ret

def parse_args(args):
    parser = OptionParser()
    parser.add_option("-l", "--list", action="store_true", dest="list", help="list all working directories")
    return parser.parse_args()

(options, args) = parse_args(sys.argv)
btt = BugToTitle(CACHE_PATH)

if options.list:
    for w, b, sb in workdir_branch_pair():
        print w.replace(os.environ['HOME'], '~')
        print "    ", btt.decoreate_git_line(b)
        if sb:
            print "      ", btt.decoreate_git_line(sb)
else:
    for i in get_branch_output().split("\n"):
        print btt.decoreate_git_line(i)
