require "../aoc"

def parse(line)
  line.split(/\s+/).map{ |line| line.to_i }
end

def step(xs)
  xs.each_cons_pair.map{ |a, b| b - a }.to_a
end

def done(xs)
  xs.all?{ |x| x == 0 }
end

def solve(xs)
  if done(xs)
    0
  else
    xs[-1] + solve(step(xs))
  end
end

puts AOC.input_lines.map{ |line| solve(parse(line)) }.sum
