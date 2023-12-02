require "../aoc"

# Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
def parse_game(line)
  id = line.match!(/^Game (\d+):/)[1].to_i
  subsets = [ ] of Hash(String, Int32)
  line.split(": ")[1].split("; ").each do |round|
    subset = Hash(String, Int32).new
    round.split(", ").each do |pair|
      words = pair.split(" ")
      subset[words[1]] = words[0].to_i
    end
    subsets = subsets.push(subset)
  end
  { id: id, rounds: subsets }
end

def game_power(game)
  maximum = {
    "red" => 0,
    "green" => 0,
    "blue" => 0,
  }

  game[:rounds].each do |round|
    round.each do |color, count|
      if count > maximum[color]
        maximum[color] = count
      end
    end
  end
  return maximum.values.product
end

puts AOC.input_lines
        .map() { |line| parse_game(line) }
        .map() { |game| game_power(game) }
        .sum
