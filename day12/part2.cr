require "../aoc"

N = 5

enum Result
  Mismatch
  Match
  Stop
end

class Solver
  @pattern : String
  @counts : Array(Int32)
  @remaining_counts : Array(Int32)
  @memo : Hash(Int32, Int64)

  def initialize(line : String)
    pattern, counts = line.split(/\s+/)
    @pattern = ([ pattern ] * N).join("?") + "."
    @counts = counts.split(',').map(&.to_i) * N
    @remaining_counts = @counts.reverse
                               .accumulate { |sum, x| sum + x + 1 }
                               .reverse
                               .push(0)
    @memo = Hash(Int32, Int64).new(-1)
  end

  def solve()
    solve(0, 0)
  end

  # pi = pattern index, ci = counts index
  def solve(pi : Int32, ci : Int32) : Int64
    key = pi << 16 | ci
    cached = @memo[key]
    if cached == -1
      cached = _solve(pi, ci)
      @memo[key] = cached
    end
    cached
  end

  def _solve(pi : Int32, ci : Int32) : Int64
    #puts "Solve #{pi}/#{ci} - #{@pattern[pi..]} #{@counts[ci..]}"
    if ci == @counts.size # no more counts remaining
      return (pi ... @pattern.size).find { |i| @pattern[i] == '#' } ? 0.to_i64 : 1.to_i64
    end

    count = @counts[ci]
    remainder = @remaining_counts[ci+1]
    inset = 0
    total : Int64 = 0.to_i64

    while pi + count + inset + remainder <= @pattern.size
      case match(pi, count, inset)
        when Result::Match
          total += solve(pi + inset + count + 1, ci+1)
        when Result::Stop
          return total
      end
      inset += 1
    end
    total
  end

  def match(pi, count, inset)
    ##puts "Match #{"." * inset}#{"#" * count}. against #{@pattern[pi..]}"
    if inset > 0 && @pattern[pi+inset-1] == '#'
      #puts "Match #{"." * inset}#{"#" * count}. against #{@pattern[pi..]} - STOP"
      return Result::Stop
    end

    # check that count chars are all either '?' or '#'
    (0 ... count).each do |i|
      p = @pattern[pi+ i + inset]
      #puts "Match #{"." * inset}#{"#" * count}. against #{@pattern[pi..]} - MISMATCH" if p == '.'
      return Result::Mismatch if p == '.'
    end

    # The last pattern needs to be a '.' or '?'
    #puts "Match #{"." * inset}#{"#" * count}. against #{@pattern[pi..]} - #{@pattern[pi + count + inset] == '#' ? "MISMATCH" : "MATCH"}"
    @pattern[pi + count + inset] == '#' ? Result::Mismatch : Result::Match
  end
end

puts AOC.input_lines
        .map { |line| Solver.new(line).solve }
        .sum
