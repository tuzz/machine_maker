# This could have been part of StepReducer, but that class was getting big.
class ConnectionReducer
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
    previous_state_equals_from
    next_state_equals_to
    starts_in_state_0

    previous_read_equals_read

    head_moves_left_if_moved_left
    head_moves_right_if_moved_right

    next_right_equals_write_if_moved_left
    next_left_equals_write_if_moved_right

    rest_of_the_tape_remains_the_same
  end

  def previous_state_equals_from
    previous_state_vars.zip(step_from_state_vars).each do |state, from|
      io.puts "-#{state} #{from}"
      io.puts "#{state} -#{from}"
    end
  end

  def next_state_equals_to
    next_state_vars.zip(step_to_state_vars).each do |state, from|
      io.puts "-#{state} #{from}"
      io.puts "#{state} -#{from}"
    end
  end

  def starts_in_state_0
    io.puts "State_#{computation}_0_0" if step.zero?
  end

  def previous_read_equals_read
    previous_read_symbol_vars.zip(step_read_symbol_vars).each do |symbol, read|
      io.puts "-#{symbol} #{read}"
      io.puts "#{symbol} -#{read}"
    end
  end

  def head_moves_left_if_moved_left
    next_positions = next_head_positions
    next_positions.unshift(nil) # offset by -1

    previous_head_positions.zip(next_positions).each do |p, n|
      next if n.nil?
      io.puts "-#{step_moves_left} -#{p} #{n}"
      io.puts "-#{step_moves_left} #{p} -#{n}"
    end

    at_left_edge = "Head_#{computation}_#{step}_0"
    io.puts "-#{at_left_edge} -#{step_moves_left}"
  end

  def head_moves_right_if_moved_right
    next_positions = next_head_positions
    next_positions.shift # offset by +1

    previous_head_positions.zip(next_positions).each do |p, n|
      next if n.nil?
      io.puts "#{step_moves_left} -#{p} #{n}"
      io.puts "#{step_moves_left} #{p} -#{n}"
    end

    at_right_edge = "Head_#{computation}_#{step}_#{cells - 1}"
    io.puts "-#{at_right_edge} #{step_moves_left}"
  end

  def next_right_equals_write_if_moved_left
    next_right_symbol_vars.zip(step_write_symbol_vars).each do |symbol, write|
      io.puts "-#{step_moves_left} -#{symbol} #{write}"
      io.puts "-#{step_moves_left} #{symbol} -#{write}"
    end
  end

  def next_left_equals_write_if_moved_right
    next_left_symbol_vars.zip(step_write_symbol_vars).each do |symbol, write|
      io.puts "#{step_moves_left} -#{symbol} #{write}"
      io.puts "#{step_moves_left} #{symbol} -#{write}"
    end
  end

  def rest_of_the_tape_remains_the_same
    previous_head_positions.each.with_index do |position, cell|
      previous_cells = previous_tape_cell_vars(cell)
      next_cells = next_tape_cell_vars(cell)

      # -Head_p -> (prev == next)
      previous_cells.zip(next_cells).each do |p, n|
        io.puts "#{position} -#{p} #{n}"
        io.puts "#{position} #{p} -#{n}"
      end
    end
  end

  private

  def previous_state_vars
    states.times.map do |state|
      "State_#{computation}_#{step}_#{state}"
    end
  end

  def next_state_vars
    states.times.map do |state|
      "State_#{computation}_#{step + 1}_#{state}"
    end
  end

  def previous_read_symbol_vars
    symbols.times.map do |symbol|
      "Symbol_#{computation}_#{step}_#{symbol}"
    end
  end

  def next_left_symbol_vars
    symbols.times.map do |symbol|
      "LeftSymbol_#{computation}_#{step + 1}_#{symbol}"
    end
  end

  def next_right_symbol_vars
    symbols.times.map do |symbol|
      "RightSymbol_#{computation}_#{step + 1}_#{symbol}"
    end
  end

  def previous_head_positions
    cells.times.map do |cell|
      "Head_#{computation}_#{step}_#{cell}"
    end
  end

  def next_head_positions
    cells.times.map do |cell|
      "Head_#{computation}_#{step + 1}_#{cell}"
    end
  end

  def step_from_state_vars
    states.times.map do |state|
      "Step_#{computation}_#{step}_From_#{state}"
    end
  end

  def step_to_state_vars
    states.times.map do |state|
      "Step_#{computation}_#{step}_To_#{state}"
    end
  end

  def step_read_symbol_vars
    symbols.times.map do |symbol|
      "Step_#{computation}_#{step}_Read_#{symbol}"
    end
  end

  def step_write_symbol_vars
    symbols.times.map do |symbol|
      "Step_#{computation}_#{step}_Write_#{symbol}"
    end
  end

  def step_moves_left
    "Step_#{computation}_#{step}_Direction"
  end

  def previous_tape_cell_vars(cell)
    symbols.times.map do |symbol|
      "Tape_#{computation}_#{step}_#{cell}_#{symbol}"
    end
  end

  def next_tape_cell_vars(cell)
    symbols.times.map do |symbol|
      "Tape_#{computation}_#{step + 1}_#{cell}_#{symbol}"
    end
  end
end
