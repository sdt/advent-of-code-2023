require "../aoc"

# Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
def game_power(line)
  # Collapse all the samples together. We only care about the highest for
  # each color.
  game = Hash(String, Int32).new(0)
  _, _, *samples = line.split(/[:;,]? /)
  samples.each_slice(2) do |iter|
    count, color = iter
    game[color] = [ count.to_i, game[color] ].max
  end
  game.values.product
end

puts AOC.input_lines
        .map() { |line| game_power(line) }
        .sum
