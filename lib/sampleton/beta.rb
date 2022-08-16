
class Sampleton::Beta
  @@PARAMS = %i[index kmer block]
  attr_accessor *@@PARAMS

  def compare(a, b)
    raise 'Undefined index.' if index.nil?
    raise "Unsupported index: #{index}." unless respond_to?(index)
    unless a.size == b.size
      raise "Incompatible profile lengths: #{a.size} != #{b.size}."
    end
    send(index, a, b)
  end

  # Estimate the "1 - Jaccard's index" distance.
  def jaccard(a, b)
    a_i = a.map { |i| i > 0 }
    b_i = b.map { |i| i > 0 } 
    n = (0 .. (a.size - 1)).map { |i| (a_i[i] && b_i[i]) ? 1 : 0 }.inject(:+)
    u = (0 .. (a.size - 1)).map { |i| (a_i[i] || b_i[i]) ? 1 : 0 }.inject(:+)
    return n.to_f / u
    #b = bray_curtis(a, b)
    #return 2.0*b/(1+b)
  end

  def mash(a, b)
    j = jaccard(a, b)
    return -Math.log(1 * j / (1 + j)) * (1 / kmer.to_f)
  end

  # Estimate the "1 - SMC" distance, where SMC: Simple Matching Coefficient.
  # Note that this distance takes into account ALL the species (including those
  # that are never observed in either sample), so it might not be comparable
  # with empirical measurements of beta diversity.
  def smc(a, b)
    a_i = a.map { |i| i > 0 ? 1 : 0 }
    b_i = b.map { |i| i > 0 ? 1 : 0 }
    m00 = (0 .. (a.size - 1)).map { |i| a_i[i] == 0 && b_i[i] == 0 ? 1 : 0 }
    m11 = (0 .. (a.size - 1)).map { |i| a_i[i] == 1 && b_i[i] == 1 ? 1 : 0 }
    return (m00 + m11).to_f / a.size
  end

  # Estimate the Bray-Curtis dissimilarity index. Note that this index does not
  # satisfy the triangle inequality. Use +jaccard+ instead if you need metric
  # distances.
  def bray_curtis(a, b)
    num = (0 .. (a.size - 1)).map { |i| (a[i] - b[i]).abs }.reduce(:+)
    den = (0 .. (a.size - 1)).map { |i| a[i] + b[i] }.reduce(:+)
    return num.to_f / den
  end

  def euclidean(a, b)
    Math.sqrt(
      (0 .. (a.size - 1)).map { |i| (a[i] - b[i])**2 }.reduce(:+)
    )
  end

  def custom(a, b)
    @custom_block ||= lambda { |a, b| eval block.to_s }
    @custom_block.call(a, b)
  end

  alias :sorensen :bray_curtis
  alias :dice :bray_curtis

end
