#!/usr/bin/env ruby

require "date"

Dir::chdir(File::join(ENV["HOME"], "work/octopress"))

if (ARGV[0] == "--pub")
  system("bash -l -c 'rvm use 1.9.2 && rake generate deploy'")
  exit
end

title = ARGV[0]
pattern = Date.today.strftime("source/_posts/%Y-%m-%d-*.markdown")
existing = Dir.glob(pattern)
if existing.empty?
  IO.popen("bash -l", "r+") do |io|
    io.write("rvm use 1.9.2\n")
    io.write("rake new_post['" + title + "']\n")
    io.write("exit\n")
    io.readlines
  end

  existing = Dir.glob(pattern)
end

print File::expand_path(existing[-1])
