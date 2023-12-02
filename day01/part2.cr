require "../aoc"

Digits = {
  "one"   => "1",
  "two"   => "2",
  "three" => "3",
  "four"  => "4",
  "five"  => "5",
  "six"   => "6",
  "seven" => "7",
  "eight" => "8",
  "nine"  => "9",
}

DigitsRegex = "(#{ (Digits.keys + Digits.values).join('|') })"

def first_digit(line)
  m = line.match!(Regex.new(DigitsRegex))
  Digits.fetch(m[1], m[1]).to_i
end

def last_digit(line)
  regex = Regex.new(DigitsRegex + "$")
  while line.size() > 0
    if m = line.match(regex)
      return Digits.fetch(m[1], m[1]).to_i
    end
    line = line.rchop
  end
  return 0
end

def calibration_value(line)
  first_digit(line) * 10 + last_digit(line)
end

output = AOC.input_lines.map() { |line| calibration_value(line) }.sum
puts(output)
