require "../aoc"

alias Vec3d = { Int128, Int128, Int128 }

TestAreaMin = 200000000000000_f64
TestAreaMax = 400000000000000_f64
#TestAreaMin = 7_f64
#TestAreaMax = 27_f64

class Line2d
  @a : Int128
  @b : Int128
  @c : Int128

  def initialize(x1 : Int128, y1 : Int128, x2 : Int128, y2 : Int128)
    @a = y2 - y1
    @b = x1 - x2
    @c = -( y1 * @b + x1 * @a )

    #puts "A=#{@a} B=#{@b} C=#{@c}"
    #puts "Ax1 + By1 + C=#{ @a * x1 + @b * y1 + @c }"
    #puts "Ax2 + By2 + C=#{ @a * x2 + @b * y2 + @c }"
  end
end

class Hailstone
  @pos : Vec3d
  @vel : Vec3d
  @line : Line2d

  def initialize(line : String)
    n = line.split(/[, @]+/).map(&.to_i128)
    @pos = { n[0], n[1], n[2] }
    @vel = { n[3], n[4], n[5] }
    @line = Line2d.new(@pos[0], @pos[1], @pos[0] + @vel[0], @pos[1] + @vel[1])
  end

  def to_s
    "#{@pos[0]}, #{@pos[1]}, #{@pos[2]} @ #{@vel[0]}, #{@vel[1]}, #{@vel[2]}"
  end

  def intersect(other : Hailstone) : Bool
    #puts "Hailstone A: #{to_s}"
    #puts "Hailstone B: #{other.to_s}"
    denom = @line.@a * other.@line.@b - @line.@b * other.@line.@a
    if denom == 0
      #puts "Hailstones' paths are parallel; they never intersect."
      return false
    end

    line1 = @line
    line2 = other.@line
    x = (line1.@b * line2.@c - line1.@c * line2.@b) / denom
    y = (line1.@c * line2.@a - line1.@a * line2.@c) / denom
    t0 = (x - @pos[0]) / @vel[0]
    t1 = (x - other.@pos[0]) / other.@vel[0]

    if t0 < 0
      if t1 < 0
        #puts "Hailstones' paths crossed in the past for both hailstones."
      else
        #puts "Hailstones' paths crossed in the past for hailstone A."
      end
      return false
    elsif t1 < 0
      #puts "Hailstones' paths crossed in the past for hailstone B."
      return false
    end

    if x < TestAreaMin || y < TestAreaMin || x > TestAreaMax || y > TestAreaMax
      #printf "Hailstones' paths will cross outside the test area (at x=%.3f, y=%.3f).\n", x, y
      return false
    end

    #printf "Hailstones' paths will cross INSIDE the test area (at x=%.3f, y=%.3f).\n", x, y

    true
  end

end


puts AOC.input_lines
        .map { |line| Hailstone.new(line) }
        .combinations(2)
        .select { |lines| lines[0].intersect(lines[1]) }
        .size
