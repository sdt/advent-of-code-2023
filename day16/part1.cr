require "../aoc"

alias Mirror = Char

class Vec2d
  def initialize(@x : Int32, @y : Int32)
  end

  def == (that : self) : Bool
    @x == that.@x && @y == that.@y
  end

  def + (that : self) : self
    Vec2d.new(@x + that.@x, @y + that.@y)
  end

  def clone
    Vec2d.new(@x, @y)
  end

  def_hash @x, @y
end

Direction = [
  Vec2d.new(1, 0), Vec2d.new(0, 1), Vec2d.new(-1, 0), Vec2d.new(0, -1)
]

enum Bearing
  East
  South
  West
  North
  Count

  def to_vec2d
    Direction[self.value]
  end
end

class Beam
  def initialize(@pos : Vec2d, @dir : Bearing)
  end

  def == (that : self) : Bool
    @pos == that.@pos && @dir == that.@dir
  end

  def move()
    @pos += @dir.to_vec2d
    self
  end

  def turn(steps : Int32) : self
    n = Bearing::Count.value
    @dir = Bearing.new((@dir.value + steps + n) % n)
    self
  end

  def clone : self
    Beam.new(@pos.clone, @dir)
  end

  def split(m : Mirror) : Array(Beam)
    if m == '.'
      return [ self ]
    end

    case @dir
      when Bearing::East, Bearing::West
        case m
          when '/'  then [ self.turn(-1) ]
          when '\\' then [ self.turn(+1) ]
          when '|'  then [ self.clone.turn(-1), self.turn(+1) ]
          else           [ self ]
        end

      when Bearing::South, Bearing::North
        case m
          when '/'  then [ self.turn(+1) ]
          when '\\' then [ self.turn(-1) ]
          when '-'  then [ self.clone.turn(-1), self.turn(+1) ]
          else           [ self ]
        end

      else [ self ]
    end
  end

  def_hash @pos, @dir
end

class Grid
  @beams : Array(Beam)
  @energised : Set(Vec2d)
  @mirrors : Hash(Vec2d, Mirror)
  @size : Vec2d

  def initialize(lines : Array(String))
    @beams = [ Beam.new(Vec2d.new(-1, 0), Bearing::East) ]
    @energised = Set(Vec2d).new
    @mirrors = Hash(Vec2d, Mirror).new('.')
    @size = Vec2d.new(lines[0].size, lines.size)

    lines.each_with_index do |line, y|
      line.chars.each_with_index do |char, x|
        if char != '.'
          pos = Vec2d.new(x, y)
          @mirrors[pos] = char
        end
      end
    end
  end

  def to_s : String
    s = ""
    (0 ... @size.@y).each do |y|
      (0 ... @size.@x).each do |x|
        s += @energised.includes?(Vec2d.new(x, y)) ? '#' : '.'
      end
      s += '\n'
    end
    s += '\n'
  end

  def run() : Int32
    while step
    end
    return @energised.size
  end

  def step()
    @beams = @beams.flat_map { |beam| step(beam) }

    return false if @beams.size == 0

    before = @energised.size
    @energised |= @beams.map(&.@pos).to_set
    after = @energised.size

    after > before
  end

  def step(beam : Beam) : Array(Beam)
    beam = beam.move()
    if on_map?(beam.@pos)
      mirror = @mirrors[beam.@pos]
      beam.split(mirror)
    else
      [ ] of Beam
    end
  end

  def on_map?(pos : Vec2d) : Bool
    pos.@x >= 0 && pos.@y >= 0 && pos.@x < @size.@x && pos.@y < @size.@y
  end
end

puts Grid.new(AOC.input_lines).run
