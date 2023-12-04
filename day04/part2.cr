require "../aoc"

def card_matches(line)
  matches = line.split(/\s*[:|]\s*/, 3)
                .skip(1)
                .map(&.split(/\s+/))
                .reduce { |acc, i| acc & i }
                .size
end

def apply_card(cards, index)
  matches, count = cards[index]
  (1..matches).each do |n|
    card = cards[index + n]
    cards[index + n] = { card[0], card[1] + count }
  end
end

def apply_cards(cards)
  (0...cards.size).each do |index|
    apply_card(cards, index)
  end
end

cards = AOC.input_lines.map { |line| { card_matches(line), 1 } }
apply_cards(cards)
puts cards.map { |card| card[1] }.sum
