require "../aoc"

class Garden
  @w : Int32
  @h : Int32

  def initialize(lines : Array(String))
    # Add a border of rocks around the grid
    @w = lines[0].size + 2
    @h = lines.size + 2
    @grid = Array(Char).new(@w * @h, '#')
    @start = 0

    i = @w + 1
    lines.each do |line|
      line.chars.each do |c|
        if c == 'S'
          @start = i
          c = '.'
        end
        @grid[i] = c
        i += 1
      end
      i += 2 # skip around the borders
    end
  end

  def step(before : Set(Int32)) : Set(Int32)
    after = Set(Int32).new
    offsets = [ -1, +1, -@w, +@w ]

    before.each do |i|
      offsets.each do |di|
        if @grid[i + di] == '.'
          after.add(i + di)
        end
      end
    end

    after
  end

  def part1(steps)
    positions = Set(Int32).new([ @start ])

    (1 .. steps).each do |step|
#      puts positions.size
      positions = step(positions)
    end
    positions.size
  end
end

g = Garden.new(AOC.input_lines)
puts g.part1(64)
