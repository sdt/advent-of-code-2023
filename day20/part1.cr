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
end

class Broadcast < Component
  def send(message : Message) : Array(Message)
    emit(message[:to], message[:pulse])
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
end

class Machine
  @component : Hash(Label, Component)
  @queue : Deque(Message)
  @count = [ 0, 0 ] of Int32

  def initialize(lines : Array(String))
    @component = Hash(Label, Component).new
    lines.each do |line|
      from, *to = line.split(/ -> |, /)
      case from[0]
        when '%'
          label = from[1..]
          @component[label] = FlipFlop.new(to)
        when '&'
          label = from[1..]
          @component[label] = Conjunction.new(to)
        else
          label = from
          @component[label] = Broadcast.new(to)
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

  def press_button
    @queue.push({ from: "button", to: "broadcaster", pulse: Pulse::Low })

    while !@queue.empty?
      input = @queue.shift
      @count[ input[:pulse].value ] += 1
      #puts "#{input[:from]} -#{input[:pulse]}-> #{input[:to]} #{@count}"
      if component = @component.fetch(input[:to], nil)
        outputs = component.send(input)
        @queue.concat(outputs)
      end
    end
  end

  def run
    (1 .. 1000).each do
      press_button
    end
    puts "#{@count[0]} x #{@count[1]}"
    @count[0] * @count[1]
  end
end

m = Machine.new(AOC.input_lines)
puts m.run
