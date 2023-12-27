require "../aoc"

alias Pt = { Int32, Int32, Int32 }

def add (a : Pt, b : Pt) Pt
  { a[0] + b[0], a[1] + b[1], a[2] + b[2] }
end

class Brick
  @@id : Int32 = 1
  @id : Int32
  @start : Pt
  @delta : Pt
  @count : Int32
  @height : Int32
  @children = Array(Brick).new
  @parents = Array(Brick).new

  def initialize(line : String)
    x0, y0, z0, x1, y1, z1 = line.split(/[,~]/).map(&.to_i)

    @id = @@id
    @@id += 1
    @start = { x0, y0, 0 }
    @count = [ x1 - x0, y1 - y0, z1 - z0 ].max + 1
    @delta = { (x1 - x0).sign, (y1 - y0).sign, (z1 - z0).sign }
    @height = z0
  end

  def name
    "n#{@id}"
  end

  def cubes(height) : Array(Pt)
    ret = Array(Pt).new(@count)
    cube = { @start[0], @start[1], height }
    ret << cube
    (2..@count).each do
      cube = add(cube, @delta)
      ret << cube
    end
    ret
  end

  def cubes(height : Int32, &)
    cube = { @start[0], @start[1], height }
    yield cube
    (2..@count).each do
      cube = add(cube, @delta)
      yield cube
    end
  end

  def set_height(height : Int32)
    @height = height
  end

  def connect(occupied : Hash(Pt, Brick))
    @parents = cubes(@height-1).map { |c| occupied.fetch(c, self) }
                               .reject { |parent| parent == self }
                               .uniq
    @parents.each { |p| p.@children << self }
  end

  def can_disintegrate?
    @children.all? { |c| c.@parents.size > 1 }
  end
end

class Well
  @bricks : Array(Brick)
  @occupied : Hash(Pt, Brick)

  def initialize(lines : Array(String))
    id = 0
    @bricks = lines.map { |line| Brick.new(line) }.sort_by(&.@height)
    @occupied = settle(@bricks)
    #pp! @occupied

    @bricks.each(&.connect(@occupied))
  end

  def settle(bricks : Array(Brick)) : Hash(Pt, Brick)
    occupied = Hash(Pt, Brick).new
    bricks.each do |brick|
      brick.set_height(settle(brick, occupied))
      brick.cubes(brick.@height) { |c| occupied[c] = brick }
    end
    bricks.sort_by!(&.@height)
    occupied
  end

  def settle(brick : Brick, occupied : Hash(Pt, Brick))
    (1 .. brick.@height-1).reverse_each do |height|
      if !can_settle(brick, occupied, height)
        return height+1
      end
    end
    1
  end

  def can_settle(brick : Brick, occupied : Hash(Pt, Brick), height : Int32) : Bool
    brick.cubes(height) { |cube| return false if occupied.has_key?(cube) }
    return true
  end

  def graph
    puts "digraph {"
    @bricks.each do |parent|
      parent.@children.each do |child|
        puts "  #{parent.name} -> #{child.name}"
      end
    end
    puts "}"
  end
end


well = Well.new(AOC.input_lines)
puts well.@bricks.select(&.can_disintegrate?).size
