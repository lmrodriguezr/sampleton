
class Sampleton

  @@_factorial = [1]

  def self.factorial(n)
    return @@_factorial[n] unless @@_factorial[n].nil?
    li = @@_factorial[0..n].size - 1
    hi = li - @@_factorial[0..li].reverse.find_index { |i| !i.nil? }
    @@_factorial[n] = ((hi + 1)..n).inject(@@_factorial[hi], :*)
  end

  def self.logfactorial(n)
    (1 .. n).map { |i| Math.log(i) }.inject(:+)
  end

  ##
  # Solve a function numerically using iterative grid expansion. A target Float
  # in the range (inclusive) defined by the two-entries Float Array +range+ is
  # found, such that when passed to the function +fx+ it results in a value
  # closer to +expect+ than +prec+. The range is divided in +grid_n+ equidistant
  # points and the point with the lowest distance is identified. If +prec+ is
  # achieved, this point is returned, otherwise the process is repeated in the
  # range with lowest distance until +prec+ is achieved. A combination of very
  # small +prec+ (high precision) and very small +grid_n+ (low resolution) might
  # result in deep recursion errors. However, larger +grid_n+ values imply
  # larger numbers of unnecessary computations, particularly in monotonic or
  # very smooth functions.
  def self.solve_numerically(range, expect = 0.0, prec = 1e-10, grid_n = 1e3,
                             &fx)
    x = (0 .. grid_n).map { |i| range[0] + (range[1] - range[0]) * i / grid_n }
    y = x.map { |i| (fx[i] - expect).abs }
    k_min = (0 .. grid_n).min { |a, b| y[a] <=> y[b] }
    return x[k_min] if y[k_min] <= prec

    (a, b) =
      (k_min == 0) ? [0, 1] :
        (k_min == grid_n || y[k_min-1] < y[k_min+1]) ?
        [k_min-1, k_min] : [k_min, k_min+1]
    return x[k_min] if a == b # <- Maximum machine precision achieved

    solve_numerically(x[a..b], expect, grid_n, prec, &fx)
  end

  # Based on http://bit.ly/2dFQVgm
  def self.rnormal(mu, sigma)
    theta = 2.0 * Math::PI * Kernel.rand
    rho = Math.sqrt(-2.0 * Math.log(1.0 - Kernel.rand))
    scale = sigma * rho
    mu + scale * Math.cos(theta)
  end

  def self.rlognormal(mu, sigma)
    Math.exp(rnormal(mu, sigma))
  end

  def self.rbinomial(n, p)
    return 0 if n == 0 || p == 0
    return n if p == 1
    cdf_exp = Kernel.rand
    q = 1.0 - p
    cdf_loop = 0.0
    (0 .. n).each do |i|
      cdf_loop += Sampleton.n_choose_k(n, i) * (p**i) * (q**(n - i))
      return i if cdf_loop >= cdf_exp
    end
    n
  end

  ##
  # Generate random numbers from a Poisson distribution with parameter +l+ using
  # inverse trasform sampling.
  def self.rpoisson(l)
    x = 0
    p = Math.exp(-l)
    s = p
    u = Kernel.rand
    while u > s
      x = x + 1
      p = p * l / x
      s = s + p
    end
    return x
  end

  ##
  # Generate a random number of sampled individuals from a pool of +n+ with
  # probability +p+. It tries to apply first normal and poisson approximations,
  # and finally uses binomial if all else fails.
  def self.rsample(n, p)
    np = n * p
    if n > 9.0 * (1.0 - p) / p && n > 9.0 * p / (1.0 - p) # 3-sd rule
      [n, [0, Sampleton.rnormal(np, Math.sqrt(np * (1.0 - p))).round].max].min
    elsif (n > 20 && p <= 0.05) || (n >= 100 && np <= 10)
      [n, Sampleton.rpoisson(np)].min
    else
      Sampleton.rbinomial(n, p)
    end
  end

  def self.n_choose_k(n, k)
    if k == 0
      1
    elsif k == 1
      n
    elsif n > 1e3
      Math.exp( logfactorial(n) - logfactorial(k) - logfactorial(n - k)).round
    else
      factorial(n) / (factorial(k) * factorial(n - k))
    end
  end
end
