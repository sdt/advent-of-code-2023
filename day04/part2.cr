require "../aoc"

alias Card = NamedTuple(name: String, matches: Int32, count: Int32)

def parse_card(line) : Card
  match = /^(Card\s+\d+):\s+(.*)\s+\|\s+(.*)\s*$/.match!(line)

  name            = match[1]
  winning_numbers = match[2].split(/ +/).map(&.to_i).to_set
  my_numbers      = match[3].split(/ +/).map(&.to_i).to_set

  {
    name: name,
    matches: (winning_numbers & my_numbers).size,
    count: 1,
  }
end

def apply_card(cards, index)
  matches = cards[index][:matches]
  count   = cards[index][:count]
  (1..matches).each do |n|
    cards[index + n] = {
      name: cards[index + n][:name],
      matches: cards[index + n][:matches],
      count: cards[index + n][:count] + count,
    }
  end
end

def apply_cards(cards)
  cards.each_with_index do |card, index|
    apply_card(cards, index)
  end
end

cards = AOC.input_lines.map { |line| parse_card(line) }
apply_cards(cards)
puts cards.map { |card| card[:count] }.sum
