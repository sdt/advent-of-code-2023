class AOC
  if ARGV.size > 1
    STDERR.puts "usage: #{PROGRAM_NAME} [input-file]"
    exit 1
  end

  def self.input_filename : String
    ARGV.size == 1 ? ARGV[0] : ENV.fetch("AOC_INPUT", "input.txt")
  end

  def self.input_lines : Array(String)
    File.read_lines(input_filename)
  end

  def self.input : String
    File.read(input_filename)
  end
end

macro pt!(value)
  puts "{{value}} # #{typeof({{value}})} => #{{{value}}}"
end
