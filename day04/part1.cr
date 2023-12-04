require "../aoc"

def card_score(line)
  count = line.split(/\s*[:|]\s*/, 3)
              .skip(1)
              .map(&.split(/\s+/))
              .reduce { |acc, i| acc & i }
              .size

  # Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  #_, winners, mine = line.split(/\s*[:|]\s*/, 3)
  #count = (winners.split(/\s+/).to_set & mine.split(/\s+/).to_set).size
  count == 0 ? 0 : 2 ** (count-1)
end

puts AOC.input_lines.map { |line| card_score(line) }.sum
