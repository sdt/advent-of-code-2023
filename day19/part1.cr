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

  def accept?(part : Part) : Bool
    node = "in"

    loop do
      node = @workflow[node].process(part)

      return true  if node == "A"
      return false if node == "R"
    end
  end
end

class Part
  @rating = Hash(Category, Int32).new

  def initialize(line)
    values = line.split(/[^0-9xmas]+/, remove_empty: true)
    values.each_slice(2, reuse: true) do |slice|
      category, rating = slice
      @rating[category[0]] = rating.to_i
    end
  end

  def rating(category : Category) : Int32
    @rating[category]
  end

  def rating
    @rating.values.sum
  end
end

code, data = AOC.input.split("\n\n")
machine = Machine.new(code.split("\n"))

puts data.split("\n", remove_empty: true)
         .map    { |line| Part.new(line) }
         .select { |part| machine.accept?(part) }
         .map    { |part| part.rating }
         .sum
