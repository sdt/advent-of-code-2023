require "../aoc"

# Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
def parse_game(line)
  game = {
    "red"   => 0,
    "green" => 0,
    "blue"  => 0,
  }

  # Collapse all the samples together. We only care about the highest for
  # each color.
  _, id, *samples = line.split(/[:;,]? /)
  samples.each_slice(2) do |iter|
    count, color = iter
    game[color] = [ count.to_i, game[color] ].max
  end
  { id: id.to_i, count: game }
end

def game_power(game)
  game[:count].values.product
end

puts AOC.input_lines
        .map() { |line| parse_game(line) }
        .map() { |game| game_power(game) }
        .sum
