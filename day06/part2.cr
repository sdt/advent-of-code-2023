require "../aoc"

# Time:      7  15   30
# Distance:  9  40  200

ChargeRate = 1

def parse(lines)
  time, distance = lines.map(&.gsub(/[^0-9]/, "").to_i64)
  { time: time, distance: distance }
end

def solve(race)
  a = (-ChargeRate).to_f64
  b = (ChargeRate * race[:time]).to_f64
  c = (-race[:distance]).to_f64

  rhs = Math.sqrt(b * b - 4 * a * c)
  s1 = (-b + rhs) / (2 * a)
  s2 = (-b - rhs) / (2 * a)

  lo = ( s1 < s2 ? s1 : s2 ).floor.to_i64 + 1
  hi = ( s1 > s2 ? s1 : s2 ).ceil.to_i64  - 1

  lo..hi
end

puts solve(parse(AOC.input_lines)).size
