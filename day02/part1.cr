require "../aoc"

Maximum = {
  "red"   => 12,
  "green" => 13,
  "blue"  => 14,
}

# Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
def parse_game(line)
  header, *rounds = line.split(/[:;] /)
  id = header.match!(/^Game (\d+)/)[1].to_i
  subsets = rounds.map do |round|
    subset = Hash(String, Int32).new
    round.split(", ").each do |pair|
      count, color = pair.split(" ")
      subset[color] = count.to_i
    end
    subset
  end
  { id: id, rounds: subsets }
end

def game_is_possible(game)
  game[:rounds].all? do |round|
    round.all? do |color, count|
      count <= Maximum[color]
    end
  end
end

puts AOC.input_lines
        .map()    { |line| parse_game(line) }
        .reject() { |game| !game_is_possible(game) }
        .map()    { |game| game[:id] }
        .sum
