
class ESEM::Sample
  @@EFFECTS = [ :annotation_effect, :sequencing_effect, :library_effect,
        :extraction_effect, :filtering_effect, :sampling_effect]
  @@PARAMS = @@EFFECTS + [:multidraw, :amplification, :noise_sd]
  attr_accessor *@@PARAMS

  def realize(profile, level=:sampling)
    idx = @@EFFECTS.find_index{ |i| "#{level}_effect".to_sym == i }
    raise "Unsupported sample level: #{level}." if idx.nil?
    if multidraw
      mds = ESEM::RealizedSample.new(profile, 1.0)
      mds.multidraw @@EFFECTS[0 .. idx].map{ |i| effect_err send(i) }
      mds
    else
      ratio = @@EFFECTS[0 .. idx].map{ |i| effect_err send(i) }.reduce(1.0, :*)
      ESEM::RealizedSample.new(profile, ratio)
    end
  end
  
  def effect_err(effect)
    return effect if effect==1 or effect.nil? or noise_sd==0 or noise_sd.nil?
    [[ESEM::rnormal(effect, noise_sd*effect), 0.0].max, 1.0].min
  end
end

class ESEM::RealizedSample
  attr :profile

  def initialize(profile, ratio)
    @profile = ratio==1 ? profile : profile.map{ |n| ESEM.rsample(n, ratio) }
  end

  def multidraw(ratios)
    ratios.each do |p|
      next if p==1
      @profile = @profile.map{ |n| ESEM.rsample(n, p) }
    end
  end

end
