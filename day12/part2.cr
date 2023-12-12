require "../aoc"

N = 4

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


def solve(pattern, counts, depth)
  if counts.size == 0
    if pattern.count('#') == 0
      #puts "#{" "*depth}Solved at depth #{depth}"
      return 1
    else
      #puts "#{" "*depth}Not solved at depth #{depth} with #{pattern} remaining"
      return 0
    end
  end

  #puts "#{" "*depth}Solve #{pattern} with #{counts} at depth #{depth}"

  count, *counts = counts
  remainder = counts.size == 0 ? 0 : counts.sum + counts.size - 1
  block = ("#" * count) + "."
  inset = 0
  total = 0

  while block.size + inset + remainder <= pattern.size
    case match(block, pattern, inset, depth)
      when Result::Match
        total += solve(pattern[inset + block.size..], counts, depth+1)
      when Result::Stop
        return total
    end
    inset += 1
  end
  total
end

def match(block, pattern, inset, depth)
  if inset > 0 && pattern[inset-1] == '#'
    #puts "#{" "*depth}Matching #{"."*inset}#{block} against #{pattern} STOP"
    return Result::Stop
  end

  block.chars.each_with_index do |b, i|
    p = pattern[i + inset]
    if (p != '?') && (p != b)
      #puts "#{" "*depth}Matching #{"."*inset}#{block} against #{pattern} false"
      return Result::Mismatch
    end
  end
  #puts "#{" "*depth}Matching #{"."*inset}#{block} against #{pattern} TRUE"
  Result::Match
end

puts AOC.input_lines
     .map { |line| puts(line) ; solve(*parse(line), 0) }
     .sum
