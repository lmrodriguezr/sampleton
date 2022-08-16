#!/usr/bin/env ruby

$:.push File.expand_path('../../lib', __FILE__)
require 'sampleton'

if ARGV.empty?
  puts <<~HELP

    Estimate the distribution of values for a beta-diversity metric between
    replicate samples from a given community

    Usage: #{$0} config.yaml [n] > result.txt

    config.yaml   Path to the configuration YAML
    n (optional)  Number of samples to simulate (default: 1000)
                  All samples are compared against one fixed reference sample
    result.txt    List of summary statistics for the distribution of
                  beta-diversity metric estimates

  HELP
  exit
end

e = Sampleton.new
e.parametrize(ARGV.first)
n = ARGV[1].to_i
n = 1_000 if n.zero?
rc = e.community.realize
rs = e.sample.realize(rc.profile)

obs = []

n.times do |i|
  qs = e.sample.realize(rc.profile)
  obs << e.beta.compare(rs.profile, qs.profile)
  e.run.advance(i + 1, n)
end
e.run.say('')

mu  = obs.inject(0.0, :+) / obs.size
mu2 = obs.map { |i| i**2 }.inject(0.0, :+) / obs.size
sd  = Math.sqrt(mu2 - mu**2)
obs.sort!

puts 'Mean:      %7e' % mu
puts 'Std. Dev.: %7e' % sd
puts 'Min:       %7e' % obs.first
puts 'Median:    %7e' % obs[(obs.size - 1) / 2]
puts 'Max:       %7e' % obs.last
puts ''
(0..10).each do |i|
  puts 'Decil %02i:  %7e' % [i, obs[((obs.size - 1) * i / 10).to_i]]
end

