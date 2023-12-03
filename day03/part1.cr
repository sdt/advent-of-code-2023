require "../aoc"

alias Coord = { Int32, Int32 }

def is_digit(c) : Bool
  c.ascii_number?
end

def is_symbol(c) : Bool
  c != '.' && !is_digit(c)
end

def make_adjacency_map(lines) : Hash(Coord, Bool)
  adjacent = Hash(Coord, Bool).new(false)
  lines.each_with_index do |line, y|
    line.chars.each_with_index do |c, x|
      next unless is_symbol(c)
      (-1..1).each do |dy|
        (-1..1).each do |dx|
          adjacent[ {x+dx, y+dy} ] = true
        end
      end
    end
  end
  return adjacent
end

def find_part_numbers(lines, adjacent) : Array(Int32)
  part_numbers = Array(Int32).new

  in_number = false
  value = 0
  is_adjacent = false
  lines.each_with_index do |line, y|
    line.chars.push('.').each_with_index do |c, x|

    if is_digit(c)
      if !in_number
        in_number = true
        is_adjacent = false
        value = 0
      end
      value = value * 10 + c.to_i
      is_adjacent |= adjacent[ {x,y} ]
    else
      if in_number
        in_number = false
        part_numbers.push(value) if is_adjacent
      end
    end

    end
  end
  return part_numbers
end

adjacent = make_adjacency_map(AOC.input_lines)
part_numbers = find_part_numbers(AOC.input_lines, adjacent)
puts(part_numbers.sum)
