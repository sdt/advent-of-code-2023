require "../aoc"

# px{a<2006:qkq,m>2090:A,rfg}

# node := [a-z+] | A | R
# cmp  := < | >
# num  := [0-9]+
# cond := <node> <cmp> <num>
# expr := <cond> : <node> , <expr> | <node>

alias Node = String
alias Category = Char   # x m a s
alias Sense = Char      # < >

Accepted = Array(PartRange).new
Rejected = Array(PartRange).new

class Rule
  @category : Category
  @sense    : Sense
  @value    : Int32
  @dest     : Node

  def initialize(text : String)
    m = /^([xmas])([<>])(\d+):([a-z]+|A|R)$/.match!(text)

    @category = m[1][0]
    @sense    = m[2][0]
    @value    = m[3].to_i
    @dest     = m[4]
  end

  def accept(part : Part) : Bool
    rating = part.rating(@category)
    @sense == '<' ? rating < @value : rating > @value
  end

  def split(part_range : PartRange) : Tuple(PartRange, PartRange)
    i = part_range.clone
    o = part_range.clone
    c = @category
    r = part_range.@range[c]

    if @sense == '<'
      i.@range[c] = r.begin .. @value - 1
      o.@range[c] = @value .. r.end
    else
      i.@range[c] = @value + 1 .. r.end
      o.@range[c] = r.begin .. @value
    end

    { i, o }
  end
end

class Workflow
  @rules   : Array(Rule)
  @default : Node

  def initialize(text : String)
    *rules, @default = text.split(',')
    @rules = rules.map { |rule| Rule.new(rule) }
  end

  def process(part : Part) : Node
    if rule = @rules.find { |rule| rule.accept(part) }
      rule.@dest
    else
      @default
    end
  end
end

class Machine
  @workflow : Hash(Node, Workflow)

  def initialize(lines : Array(String))
    @workflow = Hash(Node, Workflow).new
    lines.each do |line|
      m = /^([a-z]+){(.*)}$/.match!(line)

      node = m[1]
      workflow = Workflow.new(m[2])

      @workflow[node] = workflow
    end
  end

  def process : Int64
    process_range("in", PartRange.new)
  end

  def process_range(node : Node, range : PartRange) : Int64
    if range.size > 0
      Accepted << range if node == "A"
      Rejected << range if node == "R"
    end

    return 0_i64      if node == "R"
    return range.size if node == "A"
    return 0_i64      if range.size == 0

    total = 0_i64
    workflow = @workflow[node]
    workflow.@rules.each do |rule|
      inside, outside = rule.split(range)
      total += process_range(rule.@dest, inside)
      range = outside
    end
    total + process_range(workflow.@default, range)
  end
end

alias IntRange = Range(Int32, Int32)

def distinct?(a : IntRange, b : IntRange) : Bool
  (a.end < b.begin) || (b.end < a.begin)
end

def overlaps?(a : IntRange, b : IntRange) : Bool
  ! distinct?(a, b)
end

class PartRange
  @range : Hash(Category, IntRange)

  def initialize
    @range = Hash(Category, IntRange).new
    "xmas".chars.each do |category|
      @range[category] = 1..4000
    end
  end

  def initialize(@range : Hash(Category, IntRange))
  end

  def clone
    range = Hash(Category, IntRange).new
    @range.each { |k, v| range[k] = v.clone }
    PartRange.new(range)
  end

  def size : Int64
    @range.values.map(&.size.to_i64).product
  end

  def overlaps?(that : PartRange) : Bool
    @range.keys.all? { |k| overlaps?(@range[k], that.@range[k]) }
  end
end

code, data = AOC.input.split("\n\n")
machine = Machine.new(code.split("\n"))
puts machine.process
#
#Accepted.combinations(2).each do |pair|
#  a, b = pair
#  if a.overlaps?(b)
#    puts "OVERLAP"
#    pp! a
#    pp! b
#    puts
#  end
#end
#
#puts Accepted.map(&.size).sum
#puts Rejected.map(&.size).sum
#puts Accepted.map(&.size).sum + Rejected.map(&.size).sum
#puts PartRange.new.size
#puts 4000_i64 * 4000_i64 * 4000_i64 * 4000_i64
#
#pp! Accepted
