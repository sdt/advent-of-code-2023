require "../aoc"

alias Integer = Int32

Empty = '.'
Round = 'O'
Cube  = '#'

class Grid(T)
  @width : Integer
  @height : Integer
  @cells : Array(T)
  @outside : T

  def initialize(@width : Integer, @height : Integer, empty : T, @outside : T)
    @cells = Array(T).new(@width * @height, empty)
  end

  def index(x : Integer, y : Integer) : Nil|Integer
    if x < 0 || y < 0 || x >= @width || y >= @height
      raise IndexError.new
    end
    y * @width + x
  end

  def index!(x : Integer, y : Integer) : Nil|Integer
    if x < 0 || y < 0 || x >= @width || y >= @height
      return nil
    end
    y * @width + x
  end

  def [] (x : Integer, y : Integer ) : T
    if i = index!(x, y)
      @cells[i]
    else
      @outside
    end
  end

  def []= (x : Integer, y : Integer, t : T) : T
    @cells[index(x, y)] = t
    t
  end
end

class Dish < Grid(Char)
  def initialize(lines : Array(String))
    initialize(lines[0].size, lines.size, Empty, Cube)

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

  def spin : self
    self.tilt_north
        .tilt_west
        .tilt_south
        .tilt_east
  end

  def tilt_north : self
    (0 ... @width).each do |x|
      (1 ... @height).each do |y|
        tilt(x, y, 0, -1) if self[x, y] == Round
      end
    end
    self
  end

  def tilt_west : self
    (0 ... @height).each do |y|
      (1 ... @width).each do |x|
        tilt(x, y, -1, 0) if self[x, y] == Round
      end
    end
    self
  end

  def tilt_south : self
    (0 ... @width).each do |x|
      (0 ... @height-1).reverse_each do |y|
        tilt(x, y, 0, 1) if self[x, y] == Round
      end
    end
    self
  end

  def tilt_east : self
    (0 ... @height).each do |y|
      (0 ... @width-1).reverse_each do |x|
        tilt(x, y, 1, 0) if self[x, y] == Round
      end
    end
    self
  end

  def tilt(x : Integer, y : Integer, dx : Int32, dy : Int32)
    while self[x + dx, y + dy] == Empty
      self[x, y] = Empty
      x += dx
      y += dy
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

class DishIterator
  include Iterator(Int32)

  def initialize(lines)
    @dish = Dish.new(lines)
  end

  def next
    ret = @dish.load
    @dish.spin
    ret
  end
end

class Solver
  @solution : Int32

  def initialize(@it : DishIterator, @n : Int64)
    @xs = Array(Int32).new
    @offsets = Hash(Int32, Array(Int32)).new
    @solution = solve
  end

  def solve : Int32
    @it.each_with_index do |x, i|
      @xs << x

      offsets = @offsets.fetch(x) { Array(Int32).new }
      offsets << i
      @offsets[x] = offsets

      if is_candidate(offsets)
        offset = offsets[0]
        cycle = offsets[1] - offset
        #puts "K=#{offset} C=#{cycle}"
        index = (@n - offset) % cycle + offset
        return @xs[index]
      end
    end
    return 0
  end

  def is_candidate(indexes : Array(Int32))
    return false unless indexes.size > 3
    diff = indexes[1] - indexes[0]
    indexes.skip(1).each_cons_pair do |i, j|
      return false if j - i != diff
    end
    true
  end
end




it = DishIterator.new(AOC.input_lines)
solver = Solver.new(it, 1000 * 1000 * 1000)
puts solver.@solution
