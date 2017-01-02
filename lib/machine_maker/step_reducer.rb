class StepReducer
  def self.reduce(**params)
    new(**params).reduce
  end

  attr_accessor :computation, :step, :transitions, :symbols, :states, :io

  def initialize(computation:, step:, transitions:, symbols:, states:, io:)
    self.computation = computation
    self.step = step
    self.transitions = transitions
    self.symbols = symbols
    self.states = states
    self.io = io
  end

  def reduce
    follows_one_transition

    denormalise_transition_from_state
    denormalise_transition_to_state
    denormalise_transition_read_symbol
    denormalise_transition_write_symbol
    denormalise_transition_direction
  end

  def follows_one_transition
    CommanderVariable.exactly_one(transition_vars, io)
  end

  def denormalise_transition_from_state
    state_vars = states.times.map do |state|
      "Step_#{computation}_#{step}_From_#{state}"
    end
    CommanderVariable.exactly_one(state_vars, io)

    # Transition_t ^ From_t_state -> Step_From_state
    transition_vars.each.with_index do |transition, i|
      transition_states = transition_state_vars("From", i)

      transition_states.zip(state_vars).each do |tr_from, from|
        io.puts "-#{transition} -#{tr_from} #{from}"
      end
    end
  end

  def denormalise_transition_to_state
    state_vars = states.times.map do |state|
      "Step_#{computation}_#{step}_To_#{state}"
    end
    CommanderVariable.exactly_one(state_vars, io)

    # Transition_t ^ To_t_state -> Step_To_state
    transition_vars.each.with_index do |transition, i|
      transition_states = transition_state_vars("To", i)

      transition_states.zip(state_vars).each do |tr_to, to|
        io.puts "-#{transition} -#{tr_to} #{to}"
      end
    end
  end

  def denormalise_transition_read_symbol
    symbol_vars = symbols.times.map do |symbol|
      "Step_#{computation}_#{step}_Read_#{symbol}"
    end
    CommanderVariable.exactly_one(symbol_vars, io)

    # Transition_t ^ Read_t_symbol -> Step_Read_symbol
    transition_vars.each.with_index do |transition, i|
      transition_symbols = transition_symbol_vars("Read", i)

      transition_symbols.zip(symbol_vars).each do |tr_read, read|
        io.puts "-#{transition} -#{tr_read} #{read}"
      end
    end
  end

  def denormalise_transition_write_symbol
    symbol_vars = symbols.times.map do |symbol|
      "Step_#{computation}_#{step}_Write_#{symbol}"
    end
    CommanderVariable.exactly_one(symbol_vars, io)

    # Transition_t ^ Write_t_symbol -> Step_Write_symbol
    transition_vars.each.with_index do |transition, i|
      transition_symbols = transition_symbol_vars("Write", i)

      transition_symbols.zip(symbol_vars).each do |tr_write, write|
        io.puts "-#{transition} -#{tr_write} #{write}"
      end
    end
  end

  def denormalise_transition_direction
    direction = "Step_#{computation}_#{step}_Direction"

    # Transition_t -> (Direction_t == Step_Direction)
    transition_vars.each.with_index do |transition, i|
      tr_direction = "Direction_#{i}"

      io.puts "-#{transition} -#{tr_direction} #{direction}"
      io.puts "-#{transition} #{tr_direction} -#{direction}"
    end
  end

  def transition_vars
    @transition_vars ||= transitions.times.map do |transition|
      "StepTran_#{computation}_#{step}_#{transition}"
    end
  end

  def transition_state_vars(prefix, transition)
    states.times.map do |state|
      "#{prefix}_#{transition}_#{state}"
    end
  end

  def transition_symbol_vars(prefix, transition)
    symbols.times.map do |symbol|
      "#{prefix}_#{transition}_#{symbol}"
    end
  end
end
