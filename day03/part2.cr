require "../aoc"

alias Coord = { Int32, Int32 }

def is_digit(c) : Bool
  c.ascii_number?
end

def is_gear(c) : Bool
  c == '*'
end

def make_adjacency_map(lines) : Hash(Coord, Coord)
  adjacent = Hash(Coord, Coord).new()
  lines.each_with_index do |line, y|
    line.chars.each_with_index do |c, x|
      next unless is_gear(c)
      (-1..1).each do |dy|
        (-1..1).each do |dx|
          adjacent[ {x+dx, y+dy} ] = {x,y}
        end
      end
    end
  end
  return adjacent
end

def find_gear_ratios(lines, adjacent) : Array(Int32)
  gear_ratios = Hash(Coord, Array(Int32)).new()

  in_number = false
  value = 0
  gear = nil

  lines.each_with_index do |line, y|
    line.chars.push('.').each_with_index do |c, x|

    if is_digit(c)
      if !in_number
        in_number = true
        gear = nil
        value = 0
      end
      value = value * 10 + c.to_i
      gear ||= adjacent.fetch({x,y}, nil)
    else
      if in_number
        if gear
          gear_ratios[gear] = gear_ratios.fetch(gear, [ ] of Int32)
                                         .push(value)
        end
        in_number = false
      end
    end

    end
  end
  return gear_ratios.values.reject { |gears| gears.size < 2 }
                           .map { |gears| gears.product }
end

adjacent = make_adjacency_map(AOC.input_lines)
gear_ratios = find_gear_ratios(AOC.input_lines, adjacent)
puts(gear_ratios.sum)
