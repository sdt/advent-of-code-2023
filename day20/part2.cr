require "../aoc"

alias Label = String

enum Pulse
  Low
  High

  def invert : Pulse
    self == Low ? High : Low
  end
end

alias Message = NamedTuple(from: Label, to: Label, pulse: Pulse)

abstract class Component
  def initialize(@outputs : Array(Label))
  end

  def emit(from : Label, pulse : Pulse) : Array(Message)
    @outputs.map { |to| { from: from, to: to, pulse: pulse } }
  end

  abstract def send(message : Message) : Array(Message)
  abstract def value : Pulse
end

class Broadcast < Component
  def send(message : Message) : Array(Message)
    emit(message[:to], message[:pulse])
  end

  def value : Pulse
    Pulse::Low
  end
end

class Conjunction < Component
  @inputs = Hash(Label, Pulse).new

  def send(message : Message) : Array(Message)
    key = message[:from]
    @inputs[key] = message[:pulse]

    pulse = @inputs.values.all? { |pulse| pulse == Pulse::High } ? Pulse::Low : Pulse::High
    emit(message[:to], pulse)
  end

  def value : Pulse
    @inputs.values.all? { |pulse| pulse == Pulse::High } ? Pulse::Low : Pulse::High
  end
end

class FlipFlop < Component
  @value = Pulse::Low
  def send(message : Message) : Array(Message)
    if message[:pulse] == Pulse::Low
      @value = @value.invert
      emit(message[:to], @value)
    else
      [ ] of Message
    end
  end

  def value : Pulse
    @value
  end
end

class Machine
  @component : Hash(Label, Component)
  @queue : Deque(Message)
  @count = [ 0, 0 ] of Int32
  @dotfile_connections : String = ""

  def initialize(lines : Array(String))
    @component = Hash(Label, Component).new
    lines.each do |line|
      from, *to = line.split(/ -> |, /)
      case from[0]
        when '%'
          label = from[1..]
          @component[label] = FlipFlop.new(to)
          @dotfile_connections += "#{label} -> #{to.join(", ")}\n"
          @dotfile_connections += "#{label} [style=filled]\n"
        when '&'
          label = from[1..]
          @component[label] = Conjunction.new(to)
          @dotfile_connections += "#{label} -> #{to.join(", ")}\n"
          @dotfile_connections += "#{label} [shape=diamond style=filled]\n"
        else
          label = from
          @component[label] = Broadcast.new(to)
          @dotfile_connections += "#{label} -> #{to.join(", ")}\n"
          @dotfile_connections += "#{label} [shape=rectangle style=filled]\n"
      end
    end

    @component.each do |from, component|
      component.@outputs.each do |to|
        if @component.has_key?(to)
          if conjunction = @component[to].as?(Conjunction)
            conjunction.@inputs[from] = Pulse::Low
          end
        end
      end
    end

    @queue = Deque(Message).new
  end

  def draw_dotfile
    puts "digraph {"
    puts @dotfile_connections
    puts(@component.map do |label, component|
      color = component.value == Pulse::Low ? "green" : "red"
      "#{label} [ fillcolor=#{color} ]\n"
    end.join)
    puts "}"
  end

  def press_button(first, last)
    @queue.push({ from: "button", to: first, pulse: Pulse::Low })

    while !@queue.empty?
      input = @queue.shift
      if input[:to] == last && input[:pulse] == Pulse::Low
        return true
      end
      @count[ input[:pulse].value ] += 1
      #puts "#{input[:from]} -#{input[:pulse]}-> #{input[:to]} #{@count}"
      if component = @component.fetch(input[:to], nil)
        outputs = component.send(input)
        @queue.concat(outputs)
      end
    end
    false
  end

  def run(first, last) : Int64
    presses = 0.to_i64
    while !press_button(first, last)
      presses += 1
      #if presses % 1000 == 0 puts presses end
    end
    presses + 1
  end
end

m = Machine.new(AOC.input_lines)
puts m.run("sj", "lh") *
     m.run("pf", "mm") *
     m.run("kh", "ff") *
     m.run("cn", "fk")
