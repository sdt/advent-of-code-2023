require "../aoc"

def calibration_value(line)
  digits = line.gsub(/[^0-9]/, "")
  first = digits[0]
  last = digits[-1]
  return first.to_i * 10 + last.to_i
end

output = AOC.input_lines.map() { |line| calibration_value(line) }.sum

puts(output)
