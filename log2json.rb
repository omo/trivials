#!/usr/bin/env ruby

require 'json'
require 'time'

def parse_line(line)
  m = /^(.*?)\,(.*?)\,(.*?),(.*)$/.match(line)
  {
    #date: DateTime.iso8601(m[1]),
    date: m[1],
    hash: m[2],
    author: m[3],
    subject: m[4]
  }
end

format = '%aI,%h,%ae,%s'
entries = []

open("|git log --format=#{format}").each do |line|
  entries << parse_line(line)
end

print JSON.pretty_generate({ entries: entries })

