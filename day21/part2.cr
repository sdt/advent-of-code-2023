require "../aoc"

alias Pt = { Int32, Int32 }

class TileSet
  @tile : Hash(Pt, Set(Pt)) = Hash(Pt, Set(Pt)).new

  def add(tile_xy, offset_xy)
    if @tile.has_key?(tile_xy)
      @tile[tile_xy].add(offset_xy)
    else
      @tile[tile_xy] = Set(Pt).new([ offset_xy ])
    end
  end

  def each(&)
    @tile.each do |tile_xy, points|
      tx, ty = tile_xy
      points.each do |offset_xy|
        ox, oy = offset_xy
        yield ({ tx + ox, ty + oy })
      end
    end
  end

  def size
    @tile.each_value.map(&.size).sum
  end

  def print
    slices = @tile.keys.group_by { |key| key[1] }
    width = slices.values.map(&.size).max

    slices.keys.sort.map { |key| slices[key] }.each do |slice|
      inset = (width - slice.size) // 2
      print " " * (inset * 5)

      slice.each do |key|
        n = @tile[key].size
        case n
          when 7498
            print "+-+- "
          when 7592
            print "-+-+ "
          else
            printf "%4d ", @tile[key].size
        end
      end
      puts
    end
    puts


#    hist = Hash(Int32, Int32).new(0)
#    @tile.each_value.map(&.size).each do |size|
#      hist[size] += 1
#    end
#    puts hist.keys.sort.reverse.map { |size| "#{size}:#{hist[size]}" }.join(" ")
  end
end

class Garden
  @w : Int32
  @h : Int32
  @start : Pt = { -1, -1 }

  def initialize(lines : Array(String))
    @w = lines[0].size
    @h = lines.size
    @grid = Array(Char).new(@w * @h)

    lines.each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        if c == 'S'
          @start = { x, y }
          c = '.'
        end
        @grid << c
      end
    end
  end

  def each_move(pt, &)
    x, y = pt
    yield ({ x+1, y })
    yield ({ x, y+1 })
    yield ({ x-1, y })
    yield ({ x, y-1 })
  end

  def step(before : TileSet) : TileSet
    after = TileSet.new

    before.each do |pt|
      each_move(pt) do |pt|
        x, y = pt
        ox = x % @w
        oy = y % @h
        if @grid[oy * @w + ox] == '.'
          tx = x - ox
          ty = y - oy
          #puts "Add #{pt} => #{{ox, oy}} to #{{tx, ty}}"
          after.add({ tx, ty }, { ox, oy })
        end
      end
    end

    after
  end

  def part2(steps)
    positions = TileSet.new
    positions.add({ 0, 0 }, @start)

    (1 .. steps).each do |step|
      positions.print
      puts "#{ step-1 }: #{ positions.size }"
      puts
      positions = step(positions)
    end
    positions.print
    puts "#{ steps }: #{ positions.size }"
  end
end

g = Garden.new(AOC.input_lines)
puts g.part2(1000)
