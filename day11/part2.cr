require "../aoc"

alias Pair = Tuple(Int64, Int64)

def make_pairs(lines)
  pairs = [] of Pair

  lines.each_with_index do |line, y|
    line.chars.each_with_index do |c, x|
      if c == '#'
        pairs.push({ x.to_i64, y.to_i64 })
      end
    end
  end
  pairs
end

def make_offset_pairs(pairs)
  xs = pairs.map(&.[0]).sort
  ys = pairs.map(&.[1]).sort

  xmax = xs.max
  ymax = ys.max

  x_blanks = (0..xmax).to_a - xs
  y_blanks = (0..ymax).to_a - ys

  x_offset = make_offsets(x_blanks, xmax+1)
  y_offset = make_offsets(y_blanks, ymax+1)

  pairs.map { |p| { x_offset[p[0]], y_offset[p[1]] } }
end

def make_offsets(blanks, n)
  offsets = Array(Int64).new(n)
  blanks.push(-1)

  offset = 0
  b = 0
  (0...n).each do |i|
    if i == blanks[b]
      b += 1
      offset += 1_000_000 - 1
    end
    offsets.push(i + offset)
  end
  offsets
end

original_pairs = make_pairs(AOC.input_lines)
offset_pairs = make_offset_pairs(original_pairs)

puts offset_pairs.each_combination(2)
                 .map { |a| (a[0][0] - a[1][0]).abs + (a[0][1] - a[1][1]).abs }
                 .sum
