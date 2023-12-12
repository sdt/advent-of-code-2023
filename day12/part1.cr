require "../aoc"

def parse(line)
  pattern, counts = line.split(/\s+/)
  { pattern + ".", counts.split(',').map(&.to_i) }
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
  block = ("#" * count) + "."
  total = 0

  while block.size <= pattern.size
    if match?(block, pattern, depth)
      total += solve(pattern[block.size..], counts, depth+1)
    end
    block = "." + block
  end
  total
end

def match?(block, pattern, depth)
  block.chars.each_with_index do |b, i|
    p = pattern[i]
    if (p != '?') && (p != b)
      #puts "#{" "*depth}Matching #{block} against #{pattern} false"
      return false
    end
  end
  #puts "#{" "*depth}Matching #{block} against #{pattern} TRUE"
  true
end

puts AOC.input_lines
     .map { |line| solve(*parse(line), 0) }
     .sum
