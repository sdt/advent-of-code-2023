require "../aoc"
require "colorize"

@[Flags]
enum Bearing
  South
  North
  East
  West

  NorthEast  = North|East
  NorthWest  = North|West
  SouthEast  = South|East
  SouthWest  = South|West

  Vertical   = North|South
  Horizontal = East|West
end

Flip = {
  Bearing::North => Bearing::South,
  Bearing::South => Bearing::North,
  Bearing::East  => Bearing::West,
  Bearing::West  => Bearing::East,
}

alias Tile = NamedTuple(
  entry:   Bearing,
  exit:    Bearing,
  display: String,
  color:   Symbol,
)

struct Vec2
  @x : Int32
  @y : Int32

  def initialize(@x, @y)
  end

  def + (that : Vec2) : Vec2
    Vec2.new(@x + that.@x, @y + that.@y)
  end

  def + (bearing : Bearing) : Vec2
    return self + Direction[bearing]
  end
end

Direction = {
  Bearing::South => Vec2.new(0, +1),
  Bearing::North => Vec2.new(0, -1),
  Bearing::East  => Vec2.new(+1, 0),
  Bearing::West  => Vec2.new(-1, 0),
}

TileMap = {
  'S' => {
    entry:   Bearing::All,
    exit:    Bearing::All,
    display: "◍",
    color:   :blue,
  },
  '.' => {
    entry:   Bearing::None,
    exit:    Bearing::None,
    display: ".",
    color:   :default,
  },
  '|' => {
    entry:   Bearing::Vertical,
    exit:    Bearing::Vertical,
    display: "║",
    color:   :light_green,
  },
  '-' => {
    entry:   Bearing::Horizontal,
    exit:    Bearing::Horizontal,
    display: "═",
    color:   :light_green,
  },
  'L' => {
    entry:   Bearing::SouthWest,
    exit:    Bearing::NorthEast,
    display: "╚",
    color:   :light_green,
  },
  'J' => {
    entry:   Bearing::SouthEast,
    exit:    Bearing::NorthWest,
    display: "╝",
    color:   :light_green,
  },
  'F' => {
    entry:   Bearing::NorthWest,
    exit:    Bearing::SouthEast,
    display: "╔",
    color:   :light_green,
  },
  '7' => {
    entry:   Bearing::NorthEast,
    exit:    Bearing::SouthWest,
    display: "╗",
    color:   :light_green,
  },
}

class Actor
  @pos     : Vec2
  @bearing : Bearing
  @display : Char
  @moves   : Int32 = 0
  @alive   : Bool = true

  def initialize(@pos, @bearing, @display)
  end

  def move(new_bearing)
    @pos += @bearing
    @bearing = new_bearing
    @moves += 1
  end

  def kill()
    @alive = false
  end
end

class Game
  @grid  : Array(String)
  @start : Vec2
  @actor : Array(Actor)

  def initialize(lines)
    @grid = lines
    @start = find_start_pos(@grid)
    @actor = [
      Actor.new(@start, Bearing::North, 'N'),
      Actor.new(@start, Bearing::South, 'S'),
      Actor.new(@start, Bearing::East,  'E'),
      Actor.new(@start, Bearing::West,  'W'),
    ] of Actor
  end

  def tile(pos : Vec2) : Tile
    c = @grid[pos.@y][pos.@x]
    TileMap[c]
  end

  def step()
    @actor.select(&.@alive).each do |actor|
      move(actor)
    end
  end

  def move(actor : Actor) : Bool
    from = tile(actor.@pos)
    if (actor.@bearing.value & from[:exit].value) == 0
      actor.kill()
      return false
    end

    to_pos = actor.@pos + actor.@bearing
    to = tile(actor.@pos + actor.@bearing)
    if (actor.@bearing.value & to[:entry].value) == 0
      actor.kill()
      return false
    end

    actor.move(Bearing.new(Flip[actor.@bearing].value ^ to[:exit].value))

    true
  end

  def draw()
    return
    @grid.each_with_index do |row, y|
      row.chars.each_with_index do |c, x|
        pos = Vec2.new(x, y)
        if actor = @actor.find{ |actor| actor.@alive && actor.@pos == pos }
          print actor.@display.colorize(actor.@alive ? :green : :red)
        else
          tile = TileMap[c]
          print tile[:display].colorize(tile[:color])
        end
      end
      print "\n"
    end
    print "\n"
  end

  def ended()
    @actor.any?{ |actor| actor.@alive && actor.@pos == @start }
  end

  def run()
    draw()
    step()
    while !ended()
      draw()
      step()
    end
    draw()
  end
end

def find_start_pos(grid)
  grid.each_with_index do |row, y|
    row.chars.each_with_index do |c, x|
      if c == 'S'
        return Vec2.new(x, y)
      end
    end
  end
  Vec2.new(-1, -1)
end

game = Game.new(AOC.input_lines)
game.run
puts game.@actor.select(&.@alive).map(&.@moves).max // 2
