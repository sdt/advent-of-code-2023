require "../aoc"

alias Pair = Tuple(Int32, Int32)

def make_pairs(lines)
  pairs = [] of Pair

  lines.each_with_index do |line, y|
    line.chars.each_with_index do |c, x|
      if c == '#'
        pairs.push({ x, y })
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
  offsets = Array(Int32).new(n)
  blanks.push(-1)

  offset = 0
  b = 0
  (0...n).each do |i|
    if i == blanks[b]
      b += 1
      offset += 1
    end
    offsets.push(i + offset)
  end
  offsets
end

original_pairs = make_pairs(AOC.input_lines)
offset_pairs = make_offset_pairs(original_pairs)

puts offset_pairs.each_cartesian(offset_pairs)
                 .map { |a, b| (a[0] - b[0]).abs + (a[1] - b[1]).abs }
                 .sum // 2