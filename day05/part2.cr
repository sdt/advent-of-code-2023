require "../aoc"

alias Range64 = Range(Int64, Int64)

struct Range(B, E)
  # Clip the other range against this one.
  # If there's an overlapping part, that will be in the inside array.
  # If there's a before and/or after part, they will be in the outside array.
  # Assumes inclusive, bounded ranges.
  def clip(other : Range(B, E)) : { inside: Array(Range(B, E)), outside: Array(Range(B, E)) }
    inside  = Array(Range(B, E)).new
    outside = Array(Range(B, E)).new

    if other.@end < @begin || @end < other.@begin
      outside.push(other.clone)
      return { inside: inside, outside: outside }
    end

    if other.@begin < @begin
      outside.push(other.@begin .. @begin-1)
      other = @begin .. other.@end
    end

    if @end < other.@end
      outside.push(@end+1 .. other.@end)
      other = other.@begin .. @end
    end

    inside.push(other.clone)

    return { inside: inside, outside: outside }
  end
end

class Mapping
  @range : Range64
  @offset : Int64

  def initialize(line : String)
    to_start, from_start, n = line.split(/\s+/).map(&.to_i64)
    @range = from_start ... from_start + n -  1
    @offset = to_start - from_start
  end

  def includes?(from : Int64) : Bool
    @range.includes?(from)
  end

  def map(from : Int64) : Int64
    from + @offset
  end

  def map(from : Range64) :  { inside: Array(Range64), outside: Array(Range64) }
    clip = @range.clip(from)

    if clip[:inside].size > 0
      inside = clip[:inside]
      clip = {
        outside: clip[:outside],
        inside:  [ self.map(inside[0].begin) .. self.map(inside[0].end) ],
      }
    end

    clip
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

  def map(from : Range64) :  Array(Range64)
    ranges = Array(Range64).new

    unmapped = [ from ]

    @mappings.each do |mapping|
      next_unmapped = Array(Range64).new

      unmapped.each do |range|
        clip = mapping.map(range)

        next_unmapped.concat(clip[:outside])
        ranges.concat(clip[:inside])
      end

      unmapped = next_unmapped
    end

    ranges.concat(unmapped)
    ranges
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
  getter seeds : Array(Range64)
  @mapping_groups : Array(MappingGroup)

  def initialize(lines : Array(String))
    @seeds = lines[0].split(/\s+/)
                     .skip(1)
                     .map(&.to_i64)
                     .in_groups_of(2, 0.to_i64)
                     .map{ |p| p[0] .. p[0] + p[1] - 1 }

    @mapping_groups = lines.skip(2)
                           .slice_after(true) { |line| line == "" }
                           .map{ |lines| MappingGroup.new(lines) }
                           .collect
  end

  def map(from : Range64) : Array(Range64)
    ranges = [ from ]
    @mapping_groups.each do |group|
      ranges = ranges.flat_map{ |range| group.map(range) }
    end
    ranges
  end
end

almanac = Almanac.new(AOC.input_lines)
puts almanac.seeds.flat_map { |seed| almanac.map(seed) }
                  .map(&.begin)
                  .min
