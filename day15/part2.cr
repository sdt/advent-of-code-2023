require "../aoc"

def hash(code)
  code.chars.reduce(0) { |acc, i| acc = ((acc + i.ord) * 17) & 0xff }
end

def checksum(line)
  line.split(',').map { |code| hash(code) }.sum
end

class Lens
  getter   label        : String
  property focal_length : Int32

  def initialize(@label, @focal_length)
  end

  def to_s : String
    "[#{ label } #{ focal_length }]"
  end
end

class Carton
  @lenses = Hash(String, Int32).new

  def remove_lens(label)
    @lenses.delete(label)
  end

  def insert_lens(label, focal_length)
    @lenses[label] = focal_length
  end

  def empty? : Bool
    @lenses.empty?
  end

  def to_s : String
    @lenses.each.map { |label, focal_length| "[#{label} #{focal_length}]" }
  end

  def focusing_power(box_index : Int32)
    @lenses.values
           .each_with_index(1)
           .map { |focal_length, index| focal_length * index * box_index }
           .sum
  end
end

def solve(line)
  boxes = Array(Carton).new(256) { |i| Carton.new }

  line.split(',').each do |code|
    label, num = code.split(/[-=]/)
    index = hash(label)
    box = boxes[index]

    if num.empty?
      box.remove_lens(label)
    else
      box.insert_lens(label, num.to_i)
    end
  end

  boxes.each_with_index(1)
       .map { |box, index| box.focusing_power(index) }
       .sum
end

puts solve(AOC.input_lines[0])
