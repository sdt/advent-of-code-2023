require "../aoc"

class Node
  @neighbours = Set(String).new

  def initialize(@name : String)
  end

  def add_neighbour(name : String)
    @neighbours.add(name)
  end

  def remove_neighbour(name : String)
    @neighbours.delete(name)
  end
end

class GraphPath
  def initialize(@head : Node, @length = 0, @tail : GraphPath|Nil = nil)
  end

  def to_a : Array({ String, String })
    a = Array({ String, String }).new(@length+1)
    head = self
    while head.@tail
      tail = head.@tail.as GraphPath
      from = head.@head.@name
      to   = tail.@head.@name
      if from < to
        a << { from, to }
      else
        a << { to, from }
      end

      head = tail
    end
    a
  end
end

class Graph
  @nodes : Hash(String, Node)

  def initialize(lines : Array(String))
    @nodes = Hash(String, Node).new

    lines.each do |line|
      from_name, *to_names = line.split(/:? /)
      from = add_node(from_name)

      to_names.each do |to_name|
        to = add_node(to_name)
        from.add_neighbour(to_name)
        to.add_neighbour(from_name)
      end
    end
  end

  def part1
    minimum_cut(3)
    group_size_1 = count_connected(@nodes.first_key)
    group_size_2 = @nodes.size - group_size_1
    group_size_1 * group_size_2
  end

  def add_node(name : String)
    if @nodes.has_key?(name)
      return @nodes[name]
    end
    node = Node.new(name)
    @nodes[name] = node
    node
  end

  def shortest_path(from : String, to : String) : Array({ String, String })
    agenda = Deque(GraphPath).new
    agenda.push(GraphPath.new(@nodes[from]))
    best = Hash(String, Int32).new(Int32::MAX)
    best[from] = 0

    while agenda.size > 0
      head = agenda.shift

      next if best[head.@head.@name] < head.@length
      best[head.@head.@name] = head.@length

      head.@head.@neighbours.each do |to_name|
        length = head.@length + 1
        next if best[to_name] < length

        next_head = GraphPath.new(@nodes[to_name], length, head)
        return next_head.to_a if to_name == to

        agenda.push(next_head)
      end
    end
    puts "No path found"
    exit
    [ ] of { String, String }
  end

  def count_connected(from : String)
    reachable = Set(String).new
    agenda = Set(String).new

    agenda.add(from)

    while !agenda.empty?
      name = agenda.first
      agenda.delete(name)

      next if reachable.includes?(name)

      # Add this node to the reachable set
      reachable.add(name)

      # Add all the neighbours to the agenda that aren't already reachable
      neighbours = @nodes[name].@neighbours
      agenda |= neighbours - reachable
    end

    reachable.size
  end

  def minimum_cut(cuts : Int32)
    hist = Hash({ String, String }, Int32).new(0)

    (1..200).each do |loops|
      from = @nodes.keys.sample
      to   = @nodes.keys.sample
      next if from == to

      shortest_path(from, to).each do |edge|
        hist[edge] = hist[edge] + 1
      end

    end
#    hist.keys.sort_by { |k| hist[k] }.reverse.first(10).each do |k|
#      puts "#{k} #{hist[k]}"
#    end
    hist.keys.sort_by { |k| hist[k] }.last(3).each { |edge| remove_edge(*edge) }
  end

  def remove_edge(node0 : String, node1 : String)
    @nodes[node0].remove_neighbour(node1)
    @nodes[node1].remove_neighbour(node0)
  end
end

g = Graph.new(AOC.input_lines)
puts g.part1
