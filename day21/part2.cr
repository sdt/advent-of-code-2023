require "../aoc"

alias Pt = { Int32, Int32 }

class History
  def initialize(@start_time : Int32, size : Int32)
    @sizes = Array(Int32).new(1, size)
  end

  def add(size : Int32)
    @sizes << size
  end
end

class HistorySet
  @history = Hash(Pt, History).new

  def add(tile_xy : Pt, size : Int32, time : Int32)
    tx, ty = tile_xy
    if (tx == 0 && ty == 0) || (tx.abs + ty.abs == 2)
      if history = @history.fetch(tile_xy, nil)
        history.add(size)
      else
        puts "Creating new history set for #{tile_xy} at time #{time}"
        @history[tile_xy] = History.new(time, size)
      end
    end
  end
end

class TileSet
  @tile : Hash(Pt, Set(Pt)) = Hash(Pt, Set(Pt)).new

  def initialize(@tw : Int32, @th : Int32)
  end

  def add(x : Int32, y : Int32)
    ox = x % @tw
    oy = y % @th
    tx = (x - ox) // @tw
    ty = (y - oy) // @th

    tile_xy = { tx, ty }
    offset_xy = { ox, oy }

    if @tile.has_key?(tile_xy)
      @tile[tile_xy].add(offset_xy)
    else
      @tile[tile_xy] = Set(Pt).new([ offset_xy ])
    end
  end

  def each(&)
    @tile.each do |tile_xy, points|
      tx, ty = tile_xy
      tx *= @tw
      ty *= @th
      points.each do |offset_xy|
        ox, oy = offset_xy
        yield ({ tx + ox, ty + oy })
      end
    end
  end

  def size
    @tile.each_value.map(&.size).sum
  end

  def update_histories(history_set : HistorySet, time : Int32)
    @tile.each do |tile_xy, points|
      history_set.add(tile_xy, points.size, time)
    end
  end

  def print
    slices = @tile.keys.group_by { |key| key[1] }
    width = slices.values.map(&.size).max

    slices.keys.sort.map { |key| slices[key] }.each do |slice|
      inset = (width - slice.size) // 2
      #print " " * (inset * 5)
      print " " * (inset * 14)

      slice.sort.each do |key|
        n = @tile[key].size
        tx, ty = key
        s = case n
          when 7498 then "+-+-"
          when 7592 then "-+-+"
          else n.to_s
        end
        printf "[%4s %3d,%-3d]", s, tx, ty
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
    after = TileSet.new(@w, @h)

    before.each do |pt|
      each_move(pt) do |pt|
        x, y = pt
        ox = x % @w
        oy = y % @h
        if @grid[oy * @w + ox] == '.'
          #puts "Add #{pt} => #{{ox, oy}} to #{{tx, ty}}"
          after.add(x, y)
        end
      end
    end

    after
  end

  def part2(steps)
    positions = TileSet.new(@w, @h)
    positions.add(*@start)

    history = HistorySet.new
    positions.update_histories(history, 0)

    (1 .. steps).each do |step|
      t = step - 1
      n = positions.size
      #positions.print
      puts "#{ t },#{ n }"
#      puts
      positions = step(positions)
    end
#    positions.print
#    puts "#{ steps },#{ positions.size }"
    positions.size
  end
end

g = Garden.new(AOC.input_lines)
puts g.part2(50)
