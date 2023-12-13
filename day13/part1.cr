require "../aoc"

def parse_map(lines)
  rows = lines.map { |line| parse_line(line) }
  lines = lines.map(&.chars).transpose.map(&.join(""))
  cols = lines.map { |line| parse_line(line) }

  [ { rows, 100 }, { cols, 1 } ]
end

def parse_line(line)
  line.tr("#.", "10").to_i(base: 2)
end

def find_line_of_reflection(array)
  (1 ... array.size).to_a
                    .find(0) { |i| is_line_of_reflection(array, i) }
end

def is_line_of_reflection(array, i)
  lhs = i-1
  rhs = i
  while lhs >= 0 && rhs < array.size
    return false if array[lhs] != array[rhs]
    lhs -= 1
    rhs += 1
  end
  true
end

puts AOC.input
   .split("\n\n")
   .map(&.split("\n", remove_empty: true))
   .flat_map { |lines| parse_map(lines) }
   .map { |array, mult| mult * find_line_of_reflection(array) }
   .sum

