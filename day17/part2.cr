require "../aoc"

alias Cell = Int8

enum Bearing
  North
  East
  South
  West
end

# We only care about the count of the last bearing. It'll either be 1, 2 or 3.

alias State = NamedTuple(pos: Int32, bearing: Bearing, run: Int32)

MinRun = 4
MaxRun = 10
EmptyCellCost = 100_i8

class Grid
  @w : Int32
  @h : Int32
  @cell : Array(Cell)

  def initialize(lines : Array(String))
    # Border around the grid of zeroes
    @w = lines[0].size + 2
    @h = lines.size + 2
    @dir = [ -@w, 1, @w, -1 ]
    @cell = Array(Cell).new(@w * @h, EmptyCellCost)

    # state is [ pos, dir, prev ]
    i = @w + 1
    lines.each do |line|
      line.chars.each do |char|
        @cell[i] = char.to_i8
        i += 1
      end
      i += 2
    end
  end

  def run
    start_pos = @w + 1
    final_pos = (@h - 1) * @w - 2
    result = Int32::MAX
    best = Hash(State, Int32).new(Int32::MAX)
    agenda = Deque({ State, Int32 }).new
    [ Bearing::East, Bearing::South ].each do |bearing|
      agenda.push({ {
        pos:     start_pos + dir(bearing),
        bearing: bearing,
        run:     1,
      }, @cell[start_pos + dir(bearing)].to_i32 })
    end

    while !agenda.empty?
      from, dist = agenda.shift
      next if dist > best[from] # found a better one already

      Bearing.each do |bearing|
        if to = move?(from, bearing)
          next if to[:pos] == start_pos
          to_dist = dist + @cell[to[:pos]]
          if to[:pos] == final_pos
            if to[:run] < MinRun
              #puts "At finish, but can't stop"
            elsif to_dist < result
              #puts "New best = #{to_dist}, queue = #{agenda.size}"
              result = to_dist
            #else
              #puts "Old best = #{result}, queue = #{agenda.size}, less best = #{to_dist}"
            end
          elsif to_dist < best[to]
            best[to] = to_dist
            agenda.push({ to, to_dist })
            #puts "#{from}/#{dist} -> #{to}/#{to_dist}"
          end
        end
      end
    end
    #pp! best
    result
  end

  def dir(b : Bearing)
    @dir[b.value]
  end

  def move?(state : State, bearing : Bearing) : State|Nil
    return nil if dir(state[:bearing]) + dir(bearing) == 0
    return nil if (state[:bearing] == bearing) && (state[:run] == MaxRun)
    return nil if (state[:bearing] != bearing) && (state[:run] < MinRun)
    pos = state[:pos] + dir(bearing)
    cost = @cell[pos]
    return nil if cost == EmptyCellCost
    run = state[:bearing] == bearing ? state[:run] + 1 : 1
    { pos: pos, bearing: bearing, run: run}
  end

  def print : self
    i = @w + 1
    (1 ... @h-1).each do |y|
      (1 ... @w-1).each do |x|
        print @cell[i]
        i += 1
      end
      puts
      i += 2
    end
    self
  end

end

# 1397 too high

g = Grid.new(AOC.input_lines)
puts g.run
