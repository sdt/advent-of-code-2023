require "../aoc"

#   0123456
#
# 0 #######     span: [0..6]                        X-----X
# 1 #.....#                     > 5                 |     |
# 2 ###...#     span: [2..6]    \                   X.c   |
# 3 ..#...#                     | 3 * 3 = 9           |   |
# 4 ..#...#                     /                     |   |
# 5 ###.###     span: [0..4]    > 1                 X-c c-X
# 6 #...#..                     > 3                 |   |
# 7 ##..###     span: [1..6]    > 2                 Xc  c-X
# 8 .#....#                     > 4                  |    |
# 9 .######                     | 24 dots            X----X
#                               + 38 edges = 62

#     #      #
#     #      #
#     ##    ##
#       #####
struct Vec2d
  property x : Int32
  property y : Int32

  def initialize(@x, @y)
  end

  def == (other : self) : Bool
    @x == other.@x && @y == other.@y
  end

  def + (other : self) : Vec2d
    Vec2d.new(@x + other.@x, @y + other.@y)
  end

  def * (scale : Int32) : Vec2d
    Vec2d.new(@x * scale, @y * scale)
  end

  def min (other : self) : self
    Vec2d.new(@x < other.@x ? @x : other.@x, @y < other.@y ? @y : other.@y)
  end

  def max (other : self) : self
    Vec2d.new(@x > other.@x ? @x : other.@x, @y > other.@y ? @y : other.@y)
  end

  def_hash @x, @y
end

enum CornerType
  Convex
  Concave
  None
end

DirCode = [ 'R', 'D', 'L', 'U' ]

Direction = {
  'R' => Vec2d.new(+1, 0),
  'L' => Vec2d.new(-1, 0),
  'U' => Vec2d.new(0, -1),
  'D' => Vec2d.new(0, +1),
}

Turn = {
  "RD" => CornerType::Convex,
  "DL" => CornerType::Convex,
  "LU" => CornerType::Convex,
  "UR" => CornerType::Convex,

  "DR" => CornerType::Concave,
  "LD" => CornerType::Concave,
  "UL" => CornerType::Concave,
  "RU" => CornerType::Concave,
}

alias Corner = Vec2d

def xor_spans(xs : Array(Int32), ys : Array(Int32))
  xor = Array(Int32).new(xs.size < ys.size ? xs.size : ys.size)

  xi = 0
  yi = 0

  while xi < xs.size && yi < ys.size
    if xs[xi] == ys[yi]
      xi += 1
      yi += 1
    elsif xs[xi] < ys[yi]
      xor << xs[xi]
      xi += 1
    else
      xor << ys[yi]
      yi += 1
    end
  end
  xor = xor + xs[xi..] + ys[yi..] # One or both of xs and ys will be empty

  xor
end

def or_spans(xs : Array(Int32), ys : Array(Int32))
  (xs + ys).sort.uniq
end

class Grid

  def initialize(lines)
    pos = Vec2d.new(0, 0)
    steps = lines.map { |line| parse_line(line) }

    last_dircode = steps[-1][0]
    corner_type = Hash(Corner, CornerType).new(CornerType::None)
    steps.each do |dircode, distance|
      corner_type[pos] = Turn["#{last_dircode}#{dircode}"]
      dir = Direction[dircode]

      #puts "#{last_dircode}#{dircode} => #{corner_type[pos]} @ #{pos}"
      pos += dir * distance

      last_dircode = dircode
    end

    blocks = 0_i64
    blocks += compute_blocks(corner_type.keys)
    blocks += compute_borders(corner_type)
    puts blocks
  end

  def compute_blocks(corners)
    blocks = 0_i64

    spans = Hash(Int32, Array(Int32)).new
    corners.sort { |a, b| a.x <=> b.x }
           .group_by(&.y)
           .each { |y, ps| spans[y] = ps.map(&.x) }

    spans.each
         .to_a
         .sort { |a, b| a[0] <=> b[0] }
         .accumulate { |p, n| { n[0], xor_spans(n[1], p[1]) } }
         .each_cons_pair do |p, n|
            # Sum up each span ab cd ef
            h = n[0] - p[0] - 1       # not including horizontal edges
            if h > 0
              w = p[1].each_slice(2).map { |p| p[1] - p[0] + 1 }.sum
              #puts "#{p} #{n}"
              #puts "#{w} x #{h} = #{w * h}"
              blocks += w.to_i64 * h.to_i64
            end
          end

    blocks
  end

  def compute_borders(corner_type)
    blocks = 0_i64

    spans = Hash(Int32, Array(Int32)).new
    corners = corner_type.keys
    corners.sort { |a, b| a.x <=> b.x }
           .group_by(&.y)
           .each { |y, ps| spans[y] = ps.map(&.x) }

    spans[spans.keys.min - 1] = [] of Int32

    spans.each
         .to_a
         .sort { |a, b| a[0] <=> b[0] }
         .accumulate { |p, n| { n[0], xor_spans(n[1], p[1]) } }
         .each_cons_pair do |p, n|
            row = or_spans(p[1], n[1])
                    .map { |x| Corner.new(x, n[0]) }
                    .reject { |c| corner_type[c] == CornerType::Concave }
                    .map(&.x)
            blocks += row.each_slice(2).map { |x| x[1] - x[0] + 1 }.sum
            #puts "#{n[0]}: #{row}"
          end

    blocks
  end

  def parse_line(line)
    #words = line.split(/[^A-Za-f0-9]+/)
    #return { words[0][0], words[1].to_i32 }

    # actual part2 parsing
    _, _, hexcode = line.split(/[^A-Za-f0-9]+/)
    { DirCode[hexcode[-1].to_i], hexcode[0 ... 5].to_s.to_i(base: 16) }
    #{ hexcode[0 ... 5].to_i(base: 16), Direction[DirCode[hexcode[-1]]] }
  end

  def trace_line(pos, dir, count)
    p! dir, count
    return pos
    (0 ... count).each do |i|
      pos += dir
    end
    pos
  end
end

g = Grid.new(AOC.input_lines)
