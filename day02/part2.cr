require "../aoc"

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

def game_power(game)
  # "Project" through each color to get the counts for each, and get the max
  # Then multiply the maximums together
  colors = [ "red", "green", "blue" ]
  colors.map { |color| game[:rounds].map( &.fetch(color, 0) ).max }
        .product
end

puts AOC.input_lines
        .map() { |line| parse_game(line) }
        .map() { |game| game_power(game) }
        .sum
