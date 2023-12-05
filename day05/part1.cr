require "../aoc"

class Mapping
  @range : Range(Int64, Int64)
  @offset : Int64

  def initialize(line : String)
    to_start, from_start, n = line.split(/\s+/).map(&.to_i64)
    @range = from_start ... from_start + n
    @offset = to_start - from_start
  end

  def includes?(from : Int64) : Bool
    @range.includes?(from)
  end

  def map(from : Int64) : Int64
    from + @offset
  end
end

class MappingGroup
  @from : String
  @to   : String
  @mappings : Array(Mapping)

  def initialize(lines : Array(String))
    match = /^([a-z]+)-to-([a-z]+) map:/.match!(lines[0])
    @from = match[1]
    @to   = match[2]
    @mappings = lines.skip(1)
                     .reject{ |line| line == "" }
                     .map{ |line| Mapping.new(line) }

  end

  def map(from : Int64) : Int64
    if mapping = @mappings.find{ |mapping| mapping.includes?(from) }
      return mapping.map(from)
    end
    from
  end
end

module Iterator(T)
  def collect() : Array(T)
    array = Array(T).new
    self.each{ |t| array.push(t) }
    array
  end
end

class Almanac
  getter seeds : Array(Int64)
  @mapping_groups : Array(MappingGroup)

  def initialize(lines : Array(String))
    @seeds = lines[0].split(/\s+/).skip(1).map(&.to_i64)
    @mapping_groups = lines.skip(2)
                           .slice_after(true) { |line| line == "" }
                           .map{ |lines| MappingGroup.new(lines) }
                           .collect
  end

  def map(from : Int64) : Int64
    @mapping_groups.reduce(from) { |value, mapping| mapping.map(value) }
  end
end

almanac = Almanac.new(AOC.input_lines)
puts almanac.seeds.map{ |seed| almanac.map(seed) }.min
