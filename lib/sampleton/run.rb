
class Sampleton::Run
  @@PARAMS = %i[threads quiet]
  attr_accessor *@@PARAMS

  def initialize
    # Defaults
    @threads = 1
    @quiet = false
  end

  def say(msg, newline = true)
    return if quiet

    $stderr.print("[#{now}] #{msg}")
    $stderr.puts('') if newline
  end

  def advance(i, n)
    adv = i * 50 / n
    say("[#{'#' * adv}#{' ' * (50 - adv)}] #{i}/#{n} \r", false)
  end

  def now
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end

  ##
  # Executes the passed block with the thread number as argument (0-numbered)
  # in +threads+ processes
  def process(threads)
    threads.times do |i|
      Process.fork { yield(i) }
    end
    Process.waitall
  end

  ##
  # Distributes +enum+ across +threads+ and calls the passed block with args:
  # 1. Unitary object from +enum+
  # 2. Index of the unitary object
  # 3. Index of the acting thread
  def distribute(enum, threads, &blk)
    process(threads) { |thr| thread_enum(enum, threads, thr, &blk) }
  end

  ##
  # Enum through +enum+ executing the passed block only for thread with index
  # +thr+, one of +threads+ threads. The passed block has the same arguments
  # as the one in +#distribute+
  def thread_enum(enum, threads, thr)
    enum.each_with_index do |obj, idx|
      yield(obj, idx, thr) if idx % threads == thr
    end
  end
end
