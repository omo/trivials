#!/usr/bin/env ruby

filename = File.expand_path("~/.reclap")

started_at = Time.now
system(*ARGV)
finished_at = Time.now

delta = finished_at - started_at
print "Took #{delta} secs.\n"

open(filename, "ab") do |f|
  cmd = ARGV.join(" ")
  f.write("#{started_at.to_s},#{finished_at.to_s},#{cmd}\n")
end
