class ConfigurationReducer
  def self.reduce(**params)
    new(**params).reduce
  end

  attr_accessor :computation, :step, :symbols, :states, :cells, :io

  def initialize(computation:, step:, symbols:, states:, cells:, io:)
    self.computation = computation
    self.step = step
    self.symbols = symbols
    self.states = states
    self.cells = cells
    self.io = io
  end

  def reduce
    head_is_in_one_place
    each_tape_cell_contains_one_symbol
    in_one_state

    denormalise_read_symbol
    denormalise_left_symbol
    denormalise_right_symbol
  end

  def head_is_in_one_place
    CommanderVariable.exactly_one(position_vars, io)
  end

  def each_tape_cell_contains_one_symbol
    cells.times do |cell|
      variables = tape_cell_vars(cell)
      CommanderVariable.exactly_one(variables, io)
    end
  end

  def in_one_state
    CommanderVariable.exactly_one(state_vars, io)
  end

  def denormalise_read_symbol
    CommanderVariable.exactly_one(symbol_vars, io)

    # Head_p ^ Tape_p_s -> Symbol_s
    symbol_vars.each.with_index do |symbol, i|
      position_vars.zip(tape_symbol_vars(i)) do |position, tape_symbol|
        io.puts "-#{position} -#{tape_symbol} #{symbol}"
      end
    end
  end

  def denormalise_left_symbol
    at_left_edge = "Head_#{computation}_#{step}_0"
    CommanderVariable.exactly_one([*left_symbol_vars, at_left_edge], io)

    # Head_p ^ Tape_p-1 -> LeftSymbol_s
    left_symbol_vars.each.with_index do |symbol, i|
      tape_symbols = tape_symbol_vars(i).unshift(nil) # offset by -1

      position_vars.zip(tape_symbols) do |position, tape_symbol|
        next if tape_symbol.nil?
        io.puts "-#{position} -#{tape_symbol} #{symbol}"
      end
    end
  end

  def denormalise_right_symbol
    at_right_edge = "Head_#{computation}_#{step}_#{cells - 1}"
    CommanderVariable.exactly_one([*right_symbol_vars, at_right_edge], io)

    # Head_p ^ Tape_p+1 -> RightSymbol_s
    right_symbol_vars.each.with_index do |symbol, i|
      tape_symbols = tape_symbol_vars(i)
      tape_symbols.shift # offset by +1

      position_vars.zip(tape_symbols) do |position, tape_symbol|
        next if tape_symbol.nil?
        io.puts "-#{position} -#{tape_symbol} #{symbol}"
      end
    end
  end

  def position_vars
    @position_vars ||= cells.times.map do |cell|
      "Head_#{computation}_#{step}_#{cell}"
    end
  end

  def symbol_vars
    symbols.times.map do |symbol|
      "Symbol_#{computation}_#{step}_#{symbol}"
    end
  end

  def left_symbol_vars
    symbols.times.map do |symbol|
      "LeftSymbol_#{computation}_#{step}_#{symbol}"
    end
  end

  def right_symbol_vars
    symbols.times.map do |symbol|
      "RightSymbol_#{computation}_#{step}_#{symbol}"
    end
  end

  def state_vars
    states.times.map do |state|
      "State_#{computation}_#{step}_#{state}"
    end
  end

  def tape_cell_vars(cell)
    symbols.times.map do |symbol|
      "Tape_#{computation}_#{step}_#{cell}_#{symbol}"
    end
  end

  def tape_symbol_vars(symbol)
    cells.times.map do |cell|
      "Tape_#{computation}_#{step}_#{cell}_#{symbol}"
    end
  end
end
