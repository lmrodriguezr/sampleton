#!/usr/bin/env ruby

$:.push File.expand_path("../../lib", __FILE__)
require "esem"

if ARGV.empty?
  puts "Usage: #{$0} config.yaml"
  exit
end
e = ESEM.new
e.parametrize(ARGV.first)
rc = e.community.realize
puts "Expected richness: %d." % rc.profile.size
