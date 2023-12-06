require "../aoc"

# Time:      7  15   30
# Distance:  9  40  200

ChargeRate = 1

def parse(lines)
  lines.map { |line| line.split(/\s+/).skip(1).map(&.to_i) }
           .transpose
           .map { |pair| { time: pair[0], distance: pair[1] } }
end

def solve(race)
  a = (-ChargeRate).to_f
  b = (ChargeRate * race[:time]).to_f
  c = (-race[:distance]).to_f

  rhs = Math.sqrt(b * b - 4 * a * c)
  s1 = (-b + rhs) / (2 * a)
  s2 = (-b - rhs) / (2 * a)

  lo = ( s1 < s2 ? s1 : s2 ).floor.to_i + 1
  hi = ( s1 > s2 ? s1 : s2 ).ceil.to_i  - 1

  lo..hi
end

races = parse(AOC.input_lines)
puts races.map{ |race| solve(race).size }.product
