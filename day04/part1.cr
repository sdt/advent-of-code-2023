require "../aoc"

def card_score(line)
  words = line.split(/:? +/).skip(2)
  winning = Hash(String, Bool).new(false)

  in_my_numbers = false
  count = 0
  words.each do |word|
    if word == "|"
      in_my_numbers = true
      next
    end

    if in_my_numbers
      if winning[word]
        count += 1
      end
    else
      winning[word] = true
    end
  end
  count == 0 ? 0 : 2 ** (count-1)
end

puts AOC.input_lines.map { |line| card_score(line) }.sum
