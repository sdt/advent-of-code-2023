require "../aoc"

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

  def min (other : self) : self
    Vec2d.new(@x < other.@x ? @x : other.@x, @y < other.@y ? @y : other.@y)
  end

  def max (other : self) : self
    Vec2d.new(@x > other.@x ? @x : other.@x, @y > other.@y ? @y : other.@y)
  end

  def_hash @x, @y
end

Direction = {
  "R" => Vec2d.new(+1, 0),
  "L" => Vec2d.new(-1, 0),
  "U" => Vec2d.new(0, -1),
  "D" => Vec2d.new(0, +1),
}

class Grid
  @dug : Set(Vec2d)
  @min : Vec2d
  @max : Vec2d

  def initialize(lines)
    @dug = Set(Vec2d).new

    pos = Vec2d.new(0, 0)
    lines.each do |line|
      pos = trace_line(pos, *parse_line(line))
    end

    @min = @dug.reduce { |acc, i| acc.min(i) }
    @max = @dug.reduce { |acc, i| acc.max(i) }

    puts @dug.size
  end

  def parse_line(line)
    words = line.split(/[^A-Za-f0-9]+/)
    { Direction[words[0]], words[1].to_i32 }
  end

  def trace_line(pos, dir, count)
    (0 ... count).each do |i|
      pos += dir
      @dug.add(pos)
    end
    pos
  end

  def print
    (@min.@y .. @max.@y).each do |y|
      (@min.@x .. @max.@x).each do |x|
        print @dug.includes?(Vec2d.new(x, y)) ? '#' : '.'
      end
      puts
    end
    puts
  end

  def floodfill
    floodfill(1, 1)
  end

  def floodfill(x : Int32, y : Int32)
    if @dug.add?(Vec2d.new(x, y))
      floodfill(x - 1, y)
      floodfill(x, y - 1)
      floodfill(x + 1, y)
      floodfill(x, y + 1)
    end
  end
end

g = Grid.new(AOC.input_lines)
g.print
g.floodfill
g.print
