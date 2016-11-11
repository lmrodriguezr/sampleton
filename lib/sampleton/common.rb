require "sampleton/version"
require "sampleton/math"
require "sampleton/community"
require "sampleton/sample"
require "sampleton/beta"
require "yaml"

class Sampleton
  
  @@threads = 2
  def self.threads ; @@threads ; end
  def self.threads=(i) ; @@threads = i.to_i ; end

  attr :community, :sample, :beta

  def initialize
    @community = Sampleton::Community.new
    @sample = Sampleton::Sample.new
    @beta = Sampleton::Beta.new
  end

  def parametrize(file)
    load_yaml(file).each do |uk,uv|
      o = send(uk)
      uv.each do |k,v|
        v = v.to_sym if v.is_a? String
        o.send("#{k}=", v)
      end
    end
  end

  private
    
    def load_yaml(f)
      YAML.load(IO.read(f))
    end
  
end

