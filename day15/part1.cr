require "../aoc"

def hash(code)
  code.chars.reduce(0) { |acc, i| acc = ((acc + i.ord) * 17) & 0xff }
end

def checksum(line)
  line.split(',').map { |code| hash(code) }.sum
end

puts checksum(AOC.input_lines[0])
