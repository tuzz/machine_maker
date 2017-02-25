class ExpectationReducer
  DEFAULT_ALPHABET = %w(0 1 _)

  def self.reduce(**params)
    new(**params).reduce
  end

  attr_accessor :alphabet, :input, :output, :computation, :steps, :io

  def initialize(alphabet: nil, input:, output:, computation:, steps:, io:)
    self.alphabet = alphabet || DEFAULT_ALPHABET
    self.input = map_symbols(input)
    self.output = map_symbols(output)
    self.computation = computation
    self.steps = steps
    self.io = io

    if input.size != output.size
      raise ArgumentError, "input/output tapes must have the same size"
    end
  end

  def reduce
    initial_tape_matches_input
    final_tape_matches_output
  end

  def initial_tape_matches_input
    input.each.with_index do |symbol, cell|
      io.puts "Tape_#{computation}_0_#{cell}_#{symbol}"
    end
  end

  def final_tape_matches_output
    output.each.with_index do |symbol, cell|
      io.puts "Tape_#{computation}_#{steps}_#{cell}_#{symbol}"
    end
  end

  def map_symbols(tape)
    array = tape.is_a?(Array) ? tape : tape.split("")
    array.map { |s| alphabet.index(s) }
  end
end
