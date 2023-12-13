require "../aoc"

def parse_map(lines)
  charlines = lines.map(&.chars)

  rows = charlines.map           { |chars| parse_line(chars) }
  cols = charlines.transpose.map { |chars| parse_line(chars) }

  [ { rows, 100 }, { cols, 1 } ]
end

def parse_line(chars)
  chars.each_with_index
       .map { |char, i| (char == '#') ? 1 << i : 0 }
       .reduce(0) { |bits, bit| bits | bit }
end

def find_line_of_reflection(array)
  (1 ... array.size).to_a
                    .find(0) { |i| is_line_of_reflection_with_flipped_bit(array, i) }
end

def single_bit_set(n : Int32)
  return n & -n == n
end

def is_line_of_reflection_with_flipped_bit(array, i)
  lhs = i-1
  rhs = i
  bitflips = 0
  while lhs >= 0 && rhs < array.size
    xor = array[lhs] ^ array[rhs]
    if xor != 0
      return false if ! single_bit_set(xor)
      bitflips += 1
    end
    lhs -= 1
    rhs += 1
  end
  bitflips == 1
end

puts AOC.input
   .split("\n\n")
   .map(&.split("\n", remove_empty: true))
   .flat_map { |lines| parse_map(lines) }
   .map { |array, mult| mult * find_line_of_reflection(array) }
   .sum

