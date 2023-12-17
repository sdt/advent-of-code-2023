require "../aoc"

alias Mirror = Char

class Vec2d
  def initialize(@x : Int32, @y : Int32)
  end

  def + (that : self) : self
    Vec2d.new(@x + that.@x, @y + that.@y)
  end

  def clone
    Vec2d.new(@x, @y)
  end

  def to_s
    "[#{@x} #{@y}]"
  end
end

Direction = [
  Vec2d.new(1, 0), Vec2d.new(0, 1), Vec2d.new(-1, 0), Vec2d.new(0, -1)
]

BearingChar = [ '>', 'v', '<', '^' ]
enum Bearing
  East
  South
  West
  North
  Count

  def to_vec2d
    Direction[self.value]
  end

  def to_s
    BearingChar[self.value]
  end
end

class Beam
  def initialize(@pos : Vec2d, @dir : Bearing)
  end

  def initialize(x : Int32, y : Int32, @dir : Bearing)
    @pos = Vec2d.new(x, y)
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
    c = self.clone
    case @dir
      when Bearing::East, Bearing::West
        case m
          when '/'  then [ c.turn(-1) ]
          when '\\' then [ c.turn(+1) ]
          when '|'  then [ c.turn(-1), self.clone.turn(+1) ]
          else           [ c ]
        end

      when Bearing::South, Bearing::North
        case m
          when '/'  then [ c.turn(+1) ]
          when '\\' then [ c.turn(-1) ]
          when '-'  then [ c.turn(-1), self.clone.turn(+1) ]
          else           [ c ]
        end

      else [ c ]
    end
  end

  def to_s
    "[#{@pos.@x} #{@pos.@y} #{@dir.to_s}]"
  end
end

alias BeamKey = String
alias PosKey  = String

class Grid
  @beam_queue : Deque(Beam)
  @seen_beam : Set(BeamKey)
  @energised : Set(PosKey)
  @mirrors : Hash(PosKey, Mirror)
  @size : Vec2d

  def initialize(lines : Array(String))
    @beam_queue = Deque(Beam).new
    @seen_beam = Set(BeamKey).new

    @energised = Set(PosKey).new
    @mirrors = Hash(PosKey, Mirror).new('.')
    @size = Vec2d.new(lines[0].size, lines.size)

    lines.each_with_index do |line, y|
      line.chars.each_with_index do |char, x|
        if char != '.'
          pos = Vec2d.new(x, y)
          @mirrors[pos.to_s] = char
        end
      end
    end
  end

  def to_s : String
    s = ""
    (0 ... @size.@y).each do |y|
      (0 ... @size.@x).each do |x|
        s += @energised.includes?(Vec2d.new(x, y).to_s) ? '#' : '.'
      end
      s += '\n'
    end
    s += '\n'
  end

  def run(start : Beam) : Int32
    @beam_queue.clear
    @seen_beam.clear
    @energised.clear

    @beam_queue.push(start)

    while !@beam_queue.empty?
      beam = @beam_queue.shift
      step(beam).each do |next_beam|
        if @seen_beam.add?(next_beam.to_s)
          @beam_queue.push(next_beam)
        end
      end
    end

    @energised.size
  end

  def step(beam : Beam) : Array(Beam)
    loop do
      beam.move()
      return [ ] of Beam if ! on_map?(beam.@pos)

      key = beam.@pos.to_s
      @energised.add(key)

      mirror = @mirrors[key]
      if beam != '.'
        return beam.split(mirror)
      end
    end
  end

  def starting_points : Array(Beam)
    bs = Array(Beam).new((@size.@x + @size.@y) * 2)

    (0 ... @size.@x).each do |x|
      bs.push(Beam.new(x, -1,       Bearing::South))
      bs.push(Beam.new(x, @size.@y, Bearing::North))
    end

    (0 ... @size.@y).each do |y|
      bs.push(Beam.new(-1,       y, Bearing::East))
      bs.push(Beam.new(@size.@x, y, Bearing::West))
    end

    bs
  end

  def on_map?(pos : Vec2d) : Bool
    pos.@x >= 0 && pos.@y >= 0 && pos.@x < @size.@x && pos.@y < @size.@y
  end
end

grid = Grid.new(AOC.input_lines)
puts grid.starting_points
         .map { |start| grid.run(start) }
         .max
