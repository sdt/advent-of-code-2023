require "../aoc"

alias Integer = Int32

Empty = '.'
Round = 'O'
Cube  = '#'

class Grid(T)
  @width : Integer
  @height : Integer
  @cells : Array(T)

  def initialize(@width : Integer, @height : Integer, default : T)
    @cells = Array(T).new(@width * @height, default)
  end

  def index(x : Integer, y : Integer) : Integer
    if x < 0 || y < 0 || x >= @width || y >= @height
      raise IndexError.new
    end
    y * @width + x
  end

  def [] (x : Integer, y : Integer ) : T
    @cells[index(x, y)]
  end

  def []= (x : Integer, y : Integer, t : T) : T
    @cells[index(x, y)] = t
    t
  end
end

class Dish < Grid(Char)
  def initialize(lines : Array(String))
    initialize(lines[0].size, lines.size, Empty)

    lines.each_with_index do |line, y|
      line.chars.each_with_index do |char, x|
        if char != Empty
          self[x, y] = char
        end
      end
    end
  end

  def to_s : String
    (0 ... @height).each
                   .map { |y| @cells[y * @width ... (y+1) * @width].join }
                   .join("\n")
  end

  def tilt_north() : self
    (0 ... @width).each do |x|
      (1 ... @height).each do |y|
        tilt_north(x, y)
      end
    end
    self
  end

  def tilt_north(x : Integer, y : Integer)
    me = self[x, y]
    return unless me == Round

    while y > 0 && self[x, y-1] == Empty
      self[x, y] = Empty
      y -= 1
    end

    self[x, y] = Round
  end

  def load : Int32
    load = 0

    (0 ... @height).each do |y|
      distance = @height - y
      (0 ... @width).each do |x|
        if self[x, y] == Round
          load += distance
        end
      end
    end

    load
  end
end

puts Dish.new(AOC.input_lines).tilt_north.load
