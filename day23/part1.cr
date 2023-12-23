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

    ok, length = solve(seen, @start + @w)
    length
  end

  def solve(seen : Array(Bool), pos : Int32) : { Bool, Int32 }
    if pos == @end
      return { true, 1 } if pos == @end
    end

    #puts "Trying #{pos % @w}, #{pos // @w}"

    solved = false
    longest = 0
    seen[pos] = true

    up = pos - @w
    if !seen[up] && @cell[up] != 'v' && @cell[up] != '#'
      sub_solved, length = solve(seen, up)
      if sub_solved
        longest = max(longest, length)
        solved = true
      end
    end

    rt = pos + 1
    if !seen[rt] && @cell[rt] != '<' && @cell[rt] != '#'
      sub_solved, length = solve(seen, rt)
      if sub_solved
        longest = max(longest, length)
        solved = true
      end
    end

    dn = pos + @w
    if !seen[dn] && @cell[dn] != '^' && @cell[dn] != '#'
      sub_solved, length = solve(seen, dn)
      if sub_solved
        longest = max(longest, length)
        solved = true
      end
    end

    lf = pos - 1
    if !seen[lf] && @cell[lf] != '>' && @cell[lf] != '#'
      sub_solved, length = solve(seen, lf)
      if sub_solved
        longest = max(longest, length)
        solved = true
      end
    end

    seen[pos] = false
    { solved, longest + 1 }
  end
end

m = Map.new(AOC.input_lines)
puts m.solve
