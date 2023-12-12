require "../aoc"

N = 5

def parse(line)
  pattern, counts = line.split(/\s+/)
  pattern = ([ pattern ] * N).join("?")
  { pattern + ".", counts.split(',').map(&.to_i) * N }
end

enum Result
  Mismatch
  Match
  Stop
end

Memo = Hash(String, Int64).new(-1)

def solve(pattern, counts) : Int64
  key = pattern + counts.to_s
  cached = Memo[key]
  if cached > 0
    return cached
  end
  cached = _solve(pattern, counts)
  Memo[key] = cached
  cached
end

def _solve(pattern, counts) : Int64
  if counts.size == 0
    if pattern.count('#') == 0
      return 1.to_i64
    else
      return 0.to_i64
    end
  end

  count, *counts = counts
  remainder = counts.size == 0 ? 0 : counts.sum + counts.size - 1
  block = ("#" * count) + "."
  inset = 0
  total : Int64 = 0.to_i64

  while block.size + inset + remainder <= pattern.size
    case match(block, pattern, inset)
      when Result::Match
        total += solve(pattern[inset + block.size..], counts)
      when Result::Stop
        return total
    end
    inset += 1
  end
  total
end

def match(block, pattern, inset)
  if inset > 0 && pattern[inset-1] == '#'
    return Result::Stop
  end

  block.chars.each_with_index do |b, i|
    p = pattern[i + inset]
    if (p != '?') && (p != b)
      return Result::Mismatch
    end
  end
  Result::Match
end

puts AOC.input_lines
     .map { |line| puts(line) ; solve(*parse(line)) }
     .sum
