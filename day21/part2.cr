require "../aoc"

alias Pt = { Int32, Int32 }

class History
  @start_time : Int32
  @sizes : Array(Int32)
  @loop : Array(Int32)

  def initialize(@start_time : Int32, size : Int32)
    @sizes = Array(Int32).new(1, size)
    @loop = Array(Int32).new
  end

  def complete? : Bool
    @loop.size > 0
  end

  def add(size : Int32)
    return if complete?

    @sizes << size

    # -4 -3 -2 -1
    #  A  B  A  B
    if (@sizes.size >= 4) && (@sizes[-2] < @sizes[-1]) && (@sizes[-1] == @sizes[-3]) && (@sizes[-2] == @sizes[-4])
      time = @start_time + @sizes.size - 1

      @loop << @sizes[-2]
      @loop << @sizes[-1]
      @sizes.pop(4)
    end
  end

  def to_s(io)
    n = 8
    io << "start="
    io << @start_time
    io << ' '
    if @sizes.size > n
      io << '[' << @sizes[0 ... n-2].join(", ")
      io << ", ... "
      io << @sizes[-2] << ", " << @sizes[-1] << "]"
    else
      io << @sizes
    end
    io << " => "
    io << @loop
  end
end

class HistorySet
  @history = Hash(Pt, History).new

  def add(tile_xy : Pt, size : Int32, time : Int32)
    tx, ty = tile_xy
    if history = @history.fetch(tile_xy, nil)
      return if history.complete?
      history.add(size)
      if history.complete?
        #puts "Loop (#{history.@sizes.size}) detected in #{tile_xy} at time #{time}: #{history}"
      end
    else
      #puts "Creating new history set for #{tile_xy} at time #{time}"
      @history[tile_xy] = History.new(time, size)
    end
  end

  def complete? : Bool
    n = 3
    m = 2
    tiles = { {-n,0}, {n,0}, {0,n}, {0,-n}, {m,m}, {-m,m}, {m,-m}, {-m,-m} }

    tiles.all? { |tile_xy| @history.has_key?(tile_xy) && @history[tile_xy].complete? }
  end

  def centre(dir_xy : Pt, t : Int32)
    h = @history[dir_xy]

    t -= h.@sizes.size

    puts "#{ dir_xy }"
    puts "  #{dir_xy[0]}, #{dir_xy[1]}: count = #{h.@loop[t & 1]}"
    total = h.@loop[t & 1]
    puts "Subtotal: #{total}"
    puts

    total
  end

  def axis(dir_xy : Pt, t : Int32)
    n = 2
    dx, dy = dir_xy
    tile0 = { n     * dx, n     * dy }
    tile1 = { (n+1) * dx, (n+1) * dy }

    t0 = @history[tile0].@start_time
    dt = @history[tile1].@start_time - t0
    tiles = (t - t0) // dt + n

    puts "#{ dir_xy }"
    puts "Spawn period dt: #{dt}"
    puts "Spawn offset t0: #{t0}"
    puts "Spawn offset n: #{n}"
    puts "Tiles: #{tiles}"

    prefix = @history[tile1].@sizes
    puts "Prefix: #{prefix.size}"

    total = 0

    loop do
      tile_start_time = (tiles - n) * dt + t0
      #puts "  #{dx*tiles}, #{dy*tiles}: start time = #{tile_start_time}"
      offset = t - tile_start_time
      break if offset >= prefix.size
      #puts "  #{dx*tiles}, #{dy*tiles}: offset = #{offset}"
      puts "  #{dx*tiles}, #{dy*tiles}: count = #{prefix[offset]}"

      total += prefix[offset]

      tiles -= 1
    end

    loop = @history[tile1].@loop
    r = 0
    a = loop[(t + 0) & 1]
    b = loop[(t + 1) & 1]
    puts "Tiles remaining: #{tiles}"
    if tiles.even?
      r = (a + b) * tiles // 2
    else
      r = (a + b) * (tiles - 1) // 2 + a
    end
    total += r

    remainder = 0
    while tiles > 0
      tile_start_time = (tiles - n) * dt + t0
      offset = (t - tile_start_time - prefix.size) & 1
      puts "  #{dx*tiles}, #{dy*tiles}: count = #{loop[offset]}"

      remainder += loop[offset]

      tiles -= 1
    end

    puts "Remainder: counted=#{ remainder} computed=#{r}"
    puts "Subtotal: #{total}"
    puts

    total
  end

  def quadrant(dir_xy : Pt, t : Int32)
    n = 2
    dx, dy = dir_xy
    tile0 = { n     * dx, dy }    # eg. 2,1
    tile1 = { (n+1) * dx, dy }    # eg, 3,1

    t0 = @history[tile0].@start_time
    dt = @history[tile1].@start_time - t0
    diags = (t - t0) // dt + n

    puts "#{ dir_xy }"
    puts "Spawn period dt: #{dt}"
    puts "Spawn offset t0: #{t0}"
    puts "Spawn offset n: #{n}"
    puts "Diagonals: #{diags}"

    prefix = @history[tile0].@sizes
    puts "Prefix: #{prefix.size}"
    puts

    total = 0

    loop do
      diag_start_time = (diags - n) * dt + t0
      puts "  #{dx*diags}, #{dy}: start time = #{diag_start_time}"
      offset = t - diag_start_time
      break if offset >= prefix.size
      #puts "  #{dx*tiles}, #{dy*tiles}: offset = #{offset}"
      puts "  #{dx*diags}, #{dy}: count = #{prefix[offset]} * #{diags}"

      total += prefix[offset] * diags

      diags -= 1
    end

    loop = @history[tile0].@loop
    a = loop[(t + 1) & 1]
    b = loop[(t + 0) & 1]
    puts "A B = #{a} #{b}"

    r = 0
    if diags.even?
      r = (diags * a + (diags + 2) * b) * diags // 4
    else
      r = ((diags + 1) * a + (diags - 1) * b) * (diags + 1) // 4
    end
    total += r

    remainder = 0
    while diags > 0
      diag_start_time = (diags - n) * dt + t0
      offset = (t - diag_start_time - prefix.size) & 1
      puts "  #{dx*diags}, #{dy}: count = #{loop[offset]} * #{diags}"

      remainder += loop[offset] * diags

      diags -= 1
    end
    puts "Remainder: counted=#{ remainder} computed=#{r}"
    puts "Subtotal: #{total}"
    puts

    total
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

    t = 1
    while !history.complete?
      positions = step(positions)
      positions.update_histories(history, t)
      t += 1
    end
#    positions.print
#    puts "#{ steps },#{ positions.size }"

    # {0,N} line

    puts "Time: #{steps}"

    total = 0

    total += history.centre({0, 0}, steps)

    total += history.axis({0, 1},  steps)
    total += history.axis({0, -1}, steps)
    total += history.axis({1, 0},  steps)
    total += history.axis({-1, 0}, steps)

    total += history.quadrant({ 1,  1}, steps)
    total += history.quadrant({-1,  1}, steps)
    total += history.quadrant({-1, -1}, steps)
    total += history.quadrant({ 1, -1}, steps)

    total

  end
end

g = Garden.new(AOC.input_lines)
puts g.part2(5000)
