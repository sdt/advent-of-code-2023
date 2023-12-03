require "../aoc"

Maximum = {
  "red"   => 12,
  "green" => 13,
  "blue"  => 14,
}

# Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
def game_id(line)
  _, id, *samples = line.split(/[:;,]? /)
  samples.each_slice(2).all? do |iter|
    count, color = iter
    count.to_i <= Maximum[color]
  end ? id.to_i : 0
end

puts AOC.input_lines
        .map() { |line| game_id(line) }
        .sum
