require "../aoc"

def parse(lines)
  moves = lines[0].chars

  left = Hash(String, String).new
  right = Hash(String, String).new
  lines.skip(2).each do |line|
    from, to_left, to_right = line.split(/[^A-Z]+/)
    left[from] = to_left
    right[from] = to_right
  end

  { moves, left, right }
end

def run(moves, left, right)
  steps = 0
  node = "AAA"

  while node != "ZZZ"
    case moves[steps % moves.size]
      when 'L'
        node = left[node]
      when 'R'
        node = right[node]
    end
    steps += 1
  end

  steps
end

puts run(*(parse(AOC.input_lines)))
