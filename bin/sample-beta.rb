#!/usr/bin/env ruby

$:.push File.expand_path('../../lib', __FILE__)
require 'sampleton'

if ARGV.empty?
  puts <<~HELP

    Estimate one or more values for a beta-diversity metric between
    replicate samples from a given community

    Usage: #{$0} config.yaml [n] > result.txt

    config.yaml   Path to the configuration YAML
    n (optional)  Number of samples to simulate (default: 1)
                  All samples are compared against one fixed reference sample
    result.txt    List of beta-diversity estimates

  HELP
  exit
end
e = Sampleton.new
e.parametrize(ARGV.first)
n = (ARGV[1] || 1).to_i
rc = e.community.realize
s1 = e.sample.realize(rc.profile)
puts e.beta.index.to_s.tr('_', '-').capitalize
n.times do |i|
  e.run.advance(i + 1, n) if n > 1
  s2 = e.sample.realize(rc.profile)
  puts '%7e' % e.beta.compare(s1.profile, s2.profile)
end
e.run.say('') if n > 1

