#!/usr/bin/env ruby

$:.push File.expand_path("../../lib", __FILE__)
require "sampleton"

if ARGV.empty?
  puts "Usage: #{$0} config.yaml"
  exit
end
e = Sampleton.new
e.parametrize(ARGV.first)
rc = e.community.realize
s1 = e.sample.realize(rc.profile)
s2 = e.sample.realize(rc.profile)
puts "%s: %7e." %
  [e.beta.index.to_s.tr("_","-").capitalize,
  e.beta.compare(s1.profile, s2.profile)]

#File.open("s1.txt","w"){ |fh| s1.profile.each{ |i| fh.puts i } }
#File.open("s2.txt","w"){ |fh| s2.profile.each{ |i| fh.puts i } }
#File.open("rc.txt","w"){ |fh| rc.profile.each{ |i| fh.puts i } }
