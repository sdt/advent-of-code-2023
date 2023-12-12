require "../aoc"

def parse(line)
  pattern, rhs = line.split(/\s+/)
  counts = rhs.split(',').map(&.to_i)

  total = counts.sum
  knowns = pattern.count('#')
  unknowns = pattern.count('?')

  ons = total - knowns
  offs = unknowns - ons

  { pattern, offs, ons, counts }
end

def solve(pattern, offs, ons, counts)

  if offs == 0 && ons == 0
    return is_full_match(pattern, counts) ? 1 : 0
  end

  total = 0
  if offs > 0
    off_pattern = pattern.sub('?', '.')
    if is_partial_match(off_pattern, counts)
      total += solve(off_pattern, offs-1, ons, counts)
    end
  end
  if ons > 0
    on_pattern = pattern.sub('?', '#')
    if is_partial_match(on_pattern, counts)
      total += solve(on_pattern, offs, ons-1, counts)
    end
  end

  total
end

def is_full_match(record, counts)
  record.split(/\.+/, remove_empty: true).map(&.size) == counts
end

def is_partial_match(record, counts)
  partial = record.sub(/\?.*$/, "").split(/\.+/, remove_empty: true).map(&.size)
  return true if partial.size == 0
  return false if partial.size > counts.size
  # All but the last partial must be the same as the counts.
  # The last partial must be less or equal.
  (0 ... partial.size-1).each do |i|
    return false if partial[i] != counts[i]
  end
  return partial[-1] <= counts[partial.size-1]
end

p AOC.input_lines
     .map { |line| solve(*parse(line)) }
     .sum
