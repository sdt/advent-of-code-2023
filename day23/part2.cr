require "../aoc"

def max(x : Int32, y : Int32) : Int32
  x > y ? x : y
end

class Map
  @w : Int32
  @h : Int32
  @start : Int32
  @end : Int32
  @cell : Array(Char)

  def initialize(lines : Array(String))
    @w = lines[0].size
    @h = lines.size
    @start = 1
    @end = @w * @h - 2
    @cell = Array(Char).new(@w * @h)

    lines.each { |line| @cell += line.chars }
  end

  def solve
    seen = Array(Bool).new(@w * @h, false)
    seen[@start] = true

    solve(seen, @start + @w)
  end

  def solve(seen : Array(Bool), pos : Int32) : Int32
    if pos == @end
      return 1 if pos == @end
    end

    #puts "Trying #{pos % @w}, #{pos // @w}"

    longest = -1
    seen[pos] = true

    up = pos - @w
    if !seen[up] && @cell[up] != '#'
      longest = max(longest, solve(seen, up))
    end

    rt = pos + 1
    if !seen[rt] && @cell[rt] != '#'
      longest = max(longest, solve(seen, rt))
    end

    dn = pos + @w
    if !seen[dn] && @cell[dn] != '#'
      longest = max(longest, solve(seen, dn))
    end

    lf = pos - 1
    if !seen[lf] && @cell[lf] != '#'
      longest = max(longest, solve(seen, lf))
    end

    seen[pos] = false
    longest > 0 ? longest + 1 : -1
  end
end

m = Map.new(AOC.input_lines)
puts m.solve
