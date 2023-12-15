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
  @lenses = Array(Lens).new

  def remove_lens(label)
    @lenses.reject! { |lens| lens.label == label }
  end

  def insert_lens(label, focal_length)
    if lens = @lenses.find { |lens| lens.label == label }
      lens.focal_length = focal_length
    else
      @lenses.push(Lens.new(label, focal_length))
    end
  end

  def empty? : Bool
    @lenses.empty?
  end

  def to_s : String
    @lenses.map(&.to_s).join
  end

  def focusing_power(box_index : Int32)
    @lenses.each_with_index(1)
           .map { |lens, index| lens.focal_length * index * box_index }
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
