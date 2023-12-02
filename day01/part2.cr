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

# Digits with the keys reversed
Rdigits = Hash.zip(Digits.keys.map() { |word| word.reverse }, Digits.values)

# Match a digit, or a digit-word
DigitsRegex  = /(#{ (Digits.keys  + Digits.values ).join('|') })/

# Match a digit, or a reversed digit-word
RdigitsRegex = /(#{ (Rdigits.keys + Rdigits.values).join('|') })/

def first_digit(line)
  # Match the first "digit" we find
  m = line.match!(DigitsRegex)
  Digits.fetch(m[1], m[1]).to_i
end

def last_digit(line)
  # Match the first reversed "digit" we find in the reversed line
  m = line.reverse.match!(RdigitsRegex)
  Rdigits.fetch(m[1], m[1]).to_i
end

def calibration_value(line)
  first_digit(line) * 10 + last_digit(line)
end

output = AOC.input_lines.map() { |line| calibration_value(line) }.sum
puts(output)
