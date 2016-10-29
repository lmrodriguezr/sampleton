require "esem/version"
require "esem/math"
require "esem/community"
require "esem/sample"
require "esem/beta"
require "yaml"

class ESEM
  
  @@threads = 2
  def self.threads ; @@threads ; end
  def self.threads=(i) ; @@threads = i.to_i ; end

  attr :community, :sample, :beta

  def initialize
    @community = ESEM::Community.new
    @sample = ESEM::Sample.new
    @beta = ESEM::Beta.new
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

