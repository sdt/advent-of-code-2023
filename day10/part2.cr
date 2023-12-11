require "../aoc"
require "colorize"

alias Grid = Array(String)
alias Tile = Char

NS = '│'
WE = '─'
NE = '└'
SE = '┌'
NW = '┘'
SW = '┐'
AZ = '▣'
MT = '.'

MapIn = "|-LFJ7S"
MapOut = [ NS, WE, NE, SE, NW, SW, AZ ].join("")

enum Turn
  Left = -1
  Straight
  Right
end

enum State
  Outside
  Inside
  TopEdge
  BottomEdge
end

NextState = {
  State::Outside => {
    NS => { State::Inside,     0 },
    NE => { State::BottomEdge, 0 },
    SE => { State::TopEdge,    0 },
    MT => { State::Outside,    0 },
  },
  State::Inside => {
    NS => { State::Outside,    0 },
    NE => { State::TopEdge,    0 },
    SE => { State::BottomEdge, 0 },
    MT => { State::Inside,     1 },
  },
  State::BottomEdge => {
    WE => { State::BottomEdge, 0 },
    NW => { State::Outside,    0 },
    SW => { State::Inside,     0 },
  },
  State::TopEdge => {
    WE => { State::TopEdge,    0 },
    NW => { State::Inside,     0 },
    SW => { State::Outside,    0 },
  },
}

enum Bearing
  North
  East
  South
  West

  def turn(turn : Turn) : Bearing
    case turn
      when Turn::Left  then left()
      when Turn::Right then right()
      else                  self
    end
  end

  def left() : Bearing
    Bearing.new((self.value + 3) & 3)
  end

  def right() : Bearing
    Bearing.new((self.value + 1) & 3)
  end

  def vec2d() : Vec2d
    Unit[self.value]
  end

  def in?(mask : Int32)
    (1 << self.value) & mask != 0
  end
end

class Vec2d
  getter x : Int32
  getter y : Int32

  def initialize(@x : Int32, @y : Int32)
  end

  def + (that : Vec2d) : Vec2d
    Vec2d.new(@x + that.x, @y + that.y)
  end

  def + (that : Bearing) : Vec2d
    self + that.vec2d
  end

  def == (that : Vec2d) : Bool
    (@x == that.x) && (@y == that.y)
  end

  def to_s() : String
    "(#{@x},#{@y})"
  end
end

# LH coord system x right, y down

Unit = [
  Vec2d.new( 0, -1), # North
  Vec2d.new(+1,  0), # East
  Vec2d.new( 0, +1), # South
  Vec2d.new(-1,  0), # West
];

Move = {
  Bearing::North => {
    SW => Turn::Left,
    NS => Turn::Straight,
    SE => Turn::Right,
    NS => Turn::Straight,
  },
  Bearing::East => {
    NW => Turn::Left,
    WE => Turn::Straight,
    SW => Turn::Right,
  },
  Bearing::South => {
    NE => Turn::Left,
    NS => Turn::Straight,
    NW => Turn::Right,
  },
  Bearing::West => {
    SE => Turn::Left,
    WE => Turn::Straight,
    NE => Turn::Right,
  },
}

class Game
  @grid : Grid
  @pos : Vec2d
  @bearing : Bearing
  @start_bearing : Bearing
  @on_loop : Hash(String, Bool)

  def initialize(lines : Array(String))
    @grid = lines.map(&.tr(MapIn, MapOut))
    @pos = find_start_pos
    @bearing = @start_bearing = find_start_bearing
    @on_loop = Hash(String, Bool).new(false)
  end

  def move() : Bool
    @on_loop[@pos.to_s] = true
    next_pos = @pos + @bearing
    next_tile = get_tile(next_pos)

    if next_tile == AZ
      @pos = next_pos
      false
    elsif turn = Move[@bearing].fetch(next_tile, nil)
      @pos = next_pos
      @bearing = @bearing.turn(turn)
      true
    else
      false
    end
  end

  def trace_loop()
    print
    while move
      print
    end
    print

    @grid[@pos.y] = @grid[@pos.y].sub(AZ, start_end_tile)
    @pos = Vec2d.new(-1, -1)
  end

  def start_end_tile() : Tile
    # Flip the end bearing around so it's pointing out.
    @bearing = @bearing.turn(Turn::Right).turn(Turn::Right)
    mask = (1 << @start_bearing.value) | (1 << @bearing.value)

    if Bearing::North.in?(mask)
      if Bearing::West.in?(mask)
        return NW
      elsif Bearing::East.in?(mask)
        return NE
      else
        return NS
      end
    elsif Bearing::South.in?(mask)
      if Bearing::East.in?(mask)
        return SE
      else
        return SW
      end
    else
      return WE
    end
  end

  def get_tile(pos : Vec2d) : Tile
    if pos.y < 0 || pos.y >= @grid.size
      return '.'
    end
    if pos.x < 0 || pos.x >= @grid[0].size
      return '.'
    end

    return @grid[pos.y][pos.x]
  end

  def print()
    return
    puts
    @grid.each_with_index do |row, y|
      row.chars.each_with_index do |tile, x|
        p = Vec2d.new(x, y)
        if p == @pos
          print "☺".colorize(:yellow)
        elsif tile == AZ
          print tile.colorize(:blue)
        elsif @on_loop[p.to_s]
          print tile.colorize(:red)
        else
          print tile
        end
      end
      print "\n"
    end
    puts
    #sleep 0.05
  end

  def find_start_pos() : Vec2d
    @grid.each_with_index do |row, y|
      row.chars.each_with_index do |tile, x|
        if tile == AZ
          return Vec2d.new(x, y)
        end
      end
    end
    Vec2d.new(-1, -1)
  end

  def find_start_bearing() : Bearing
    bearing = Bearing::North
    loop do
      next_pos = @pos + bearing
      next_tile = get_tile(next_pos)
      if Move[bearing].fetch(next_tile, nil)
        return bearing
      end
      bearing = bearing.turn(Turn::Right)
    end
  end

  def count_inside : Int32
    inside = 0

    @grid.each_with_index do |row, y|
      state = State::Outside
      row.chars.each_with_index do |tile, x|
        tile = MT unless @on_loop[Vec2d.new(x, y).to_s]

        state_count = NextState[state].fetch(tile, { state, 0 })
        state = state_count[0]
        inside += state_count[1]
      end
    end

    inside
  end

end

game = Game.new(AOC.input_lines)
game.trace_loop
game.print
puts game.count_inside
