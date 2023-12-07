require "../aoc"

enum Type
  HighCard
  OnePair
  TwoPair
  ThreeOfAKind
  FullHouse
  FourOfAKind
  FiveOfAKind
end

class Hand
  @cards : String
  @type : Type
  @ordering : String
  @bid : Int64

  def <=> (other : self)
    type_cmp = @type <=> other.@type
    return type_cmp != 0 ? type_cmp : @ordering <=> other.@ordering
  end

  def initialize(line : String)
    @cards, bid = line.split(/\s+/)
    @type = classify(@cards)
    @ordering = ordering(@cards)
    @bid = bid.to_i64
  end

  def classify(cards : String) : Type
    hist = cards.chars.tally
    buckets = hist.size
    product = hist.values.product

    case buckets
      when 1
        return Type::FiveOfAKind
      when 2
        case product # 3,2 or 4,1
          when 4
            return Type::FourOfAKind
          when 6
            return Type::FullHouse
        end
      when 3
        case product # 3,1,1 or 2,2,1
          when 3
            return Type::ThreeOfAKind
          when 4
            return Type::TwoPair
        end
      when 4
        return Type::OnePair
    end
    return Type::HighCard
  end

  def ordering(cards : String) String
    return cards.tr("23456789TJQKA", "abcdefghijklm")
  end
end

puts AOC.input_lines
        .map{ |line| Hand.new(line) }
        .sort!
        .map_with_index(1) { |card, i| i * card.@bid }
        .sum
