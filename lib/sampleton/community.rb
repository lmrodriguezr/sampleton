
class Sampleton::Community
  @@PARAMS = %i[distribution method nt_nmax nt assume]
  attr_accessor *@@PARAMS
  
  def realize
    case distribution.to_sym
    when :lognormal
      return realize_lognormal
    else
      raise "Unsupported distribution: #{distribution}."
    end
  end

  private

    def realize_lognormal
      case method.to_sym
      when :nt_nmax
        return realize_lognormal_nt_nmax
      else
        raise "Unsupported method for lognormal: #{method}."
      end
    end

    def realize_lognormal_nt_nmax
      case assume.to_sym
      when :preston
        # Estimate `a` and `st` from Eqs. 8-9 in Curtis et al 2002
        nmax = nt / nt_nmax
        a = Sampleton.solve_numerically([0.0, 1.0], 1.0) do |a|
          curtis_eq_9(a, nmax) / nt
        end
        st = curtis_eq_8(a).ceil
      when :nmin_1
        # Estimate `a` and `st` from Eq. 10-11 in Curtis et al 2002
        nmax = nt / nt_nmax
        a = Sampleton.solve_numerically([0.0, 1.0], 1.0) do |a|
          curtis_eq_11(a, 1, nmax) / nt
        end
        st = curtis_eq_10(a, nmax, 1.0).ceil
      else
        raise "Unsupported assumption for lognormal with NT/Nmax: #{assume}."
      end

      # Estimate lnN(mu, var) parameters
      mu = Math.log2(Math.sqrt(nmax))
      sd = Math.sqrt(1.0 / ((a**2) * 2.0 * Math.log(2)) )

      # Realize community
      rco = Sampleton::RealizedCommunity.new(st)
      (1 .. st).each do |i|
        rco[i - 1] = Sampleton.rlognormal(mu, sd).round
      end

      return rco
    end

    def curtis_eq_9(a, nmax)
      Math.sqrt(Math::PI) * Math.erf(Math.log(2) / a) * nmax / (a * 2)
    end

    def curtis_eq_8(a)
      Math.sqrt(Math::PI) * Math.exp((Math.log(2) / (a * 2))**2) / a
    end

    def curtis_eq_11(a, nmin, nmax)
      als = a * Math.log2(Math.sqrt(nmax / nmin))
      l2a = Math.log(2) / (2.0 * a)
      p1 = Math.sqrt(Math::PI * nmin * nmax) / (2.0 * a)
      p2 = Math.exp(als**2) * Math.exp(l2a**2)
      p3 = Math.erf(als - l2a) + Math.erf(als + l2a)
      return 1.0 if p3 == 0
      p1 * p2 * p3
    end

    def curtis_eq_10(a, nmax, nmin)
      Math.sqrt(Math::PI) *
        Math.exp((a * Math.log2(Math.sqrt(nmax / nmin)))**2) / a
    end
end

class Sampleton::RealizedCommunity
  attr :profile

  def initialize(richness)
    @profile = Array.new(richness, 0)
  end

  def [](k)
    @profile[k]
  end

  def []=(k, v)
    @profile[k] = v
  end
end
