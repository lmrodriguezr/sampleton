#!/usr/bin/env ruby

$:.push File.expand_path('../../lib', __FILE__)
require 'sampleton'

if ARGV.empty?
  puts <<~HELP

    Estimate the richness of the community (St) based on the parameters provided

    Usage: #{$0} config.yaml

    config.yaml   Path to the configuration YAML

  HELP
  exit
end
e = Sampleton.new
e.parametrize(ARGV.first)
rc = e.community.realize
puts 'Expected richness: %d.' % rc.profile.size
