require "../aoc"

Base = { "red" => 0, "green" => 0, "blue" => 0 }

# Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
def game_power(line)
  # Collapse all the samples together. We only care about the highest for
  # each color.
  line.split(/[:;,]? /).skip(2).each_slice(2).reduce(Base) do |game, iter|
    count, color = iter
    game.merge({ color => [ count.to_i, game[color] ].max })
  end.values.product
end

puts AOC.input_lines
        .map() { |line| game_power(line) }
        .sum
