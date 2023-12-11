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

MapIn = "|-LFJ7S"
MapOut = [ NS, WE, NE, SE, NW, SW, AZ ].join("")

enum Turn
  Left = -1
  Straight
  Right
end

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
  @start_pos : Vec2d
  @start_bearing : Bearing

  def initialize(lines : Array(String))
    @grid = lines.map(&.tr(MapIn, MapOut))
    @pos = @start_pos = find_start_pos
    @bearing = @start_bearing = find_start_bearing
  end

  def move() : Bool
    next_pos = @pos + @bearing
    next_tile = get_tile(next_pos)

    if next_pos == @start_pos
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
    puts
    @grid.each_with_index do |row, y|
      row.chars.each_with_index do |tile, x|
        p = Vec2d.new(x, y)
        if p == @pos
          print "☺".colorize(:yellow)
        elsif p == @start_pos
          print tile.colorize(:blue)
        else
          print tile
        end
      end
      print "\n"
    end
    puts
    sleep 0.05
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
      next_pos = @start_pos + bearing
      next_tile = get_tile(next_pos)
      if Move[bearing].fetch(next_tile, nil)
        return bearing
      end
      bearing = bearing.turn(Turn::Right)
    end
  end

end

game = Game.new(AOC.input_lines)
game.print
moves = 0
while game.move
  game.print
  moves += 1
end
game.print
puts (moves+1) // 2
