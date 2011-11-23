#!/usr/bin/env ruby

require 'optparse'

SUFFIXES = ['.c', '.cpp', '.cc', '.h', '.hpp', '.y' , '.java', '.pm', '.pl', '.rb', '.py', '.as', '.C', '.H', '.CPP', '.cgi', '.js', '.scala', '.thrift']
SKIPS    = ['.svn']

def suffix_match? name
  SUFFIXES.any?{ |i| i == File.extname(name) }
end

def skip? name
  SKIPS.any?{ |i| i == File.extname(name) }
end

class LineTracer

  attr_reader :root, :depth_limit, :dir_only

  def initialize(root, depth_limit, dir_only)
    @root = root
    @depth_limit = depth_limit
    @dir_only = dir_only
  end

  def eliminate_root(path)
    path.gsub(root.path, "")
  end

  def print depth, lines, path
    if (depth <= depth_limit and 0 < lines and 
        (!dir_only or File.directory?(path)))
      printf("%10d %s\n", lines, eliminate_root(path))
    end
  end

  def trace_lines(dir, depth)
    n = 0
    dir.each do |i|
      path = File.expand_path(i, dir.path)
      next if skip? path
      if File.file?(path)
        if suffix_match?(path)
          c = open(path).readlines.size
          print(depth, c, path)
          n += c
        end
      else
        if path.include?(dir.path) and path != dir.path # ".."
          n += trace_lines(Dir.new(path), depth+1)
        end
      end
    end

    print(depth, n, dir.path)

    return n
  end
end

#
# bootstrap
#

depth_limit = 256 # large enough...
dir_only = false

parser = OptionParser.new
parser.on("-l", "--limit=LIMIT", String, 
          "set directory depth limit to print") do |arg|
  depth_limit = arg.to_i
end

parser.on("-d", "--directory", String, 
          "print directory only") do 
  dir_only = true
end

begin
  parser.parse!
  total = ARGV.map do |i|
    root = Dir.new(File.expand_path(i))
    LineTracer.new(root, depth_limit, dir_only).trace_lines(root, 0)
  end.inject do |a,i|
    a += i
  end

  print "---\n"
  print "total: #{total}\n"
end
