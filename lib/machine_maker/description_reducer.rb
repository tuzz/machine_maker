class DescriptionReducer
  def self.reduce(**params)
    new(**params).reduce
  end

  attr_accessor :transitions, :symbols, :states, :io

  def initialize(transitions:, symbols:, states:, io:)
    self.transitions = transitions
    self.symbols = symbols
    self.states = states
    self.io = io
  end

  def reduce
    each_transition_goes_from_one_state
    each_transition_goes_to_one_state
    each_transition_reads_one_symbol
    each_transition_writes_one_symbol
    each_transition_moves_left_or_right

    machine_is_deterministic
  end

  def each_transition_goes_from_one_state
    transitions.times do |transition|
      variables = state_vars("From", transition)
      CommanderVariable.exactly_one(variables, io)
    end
  end

  def each_transition_goes_to_one_state
    transitions.times do |transition|
      variables = state_vars("To", transition)
      CommanderVariable.exactly_one(variables, io)
    end
  end

  def each_transition_reads_one_symbol
    transitions.times do |transition|
      variables = symbol_vars("Read", transition)
      CommanderVariable.exactly_one(variables, io)
    end
  end

  def each_transition_writes_one_symbol
    transitions.times do |transition|
      variables = symbol_vars("Write", transition)
      CommanderVariable.exactly_one(variables, io)
    end
  end

  # We can represent this with a single variable, so we don't need to do
  # anything. When used outside this reducer, we'll use: Direction_#{transition}
  # and the convention that true=left, false=right.
  def each_transition_moves_left_or_right
    # noop
  end

  def machine_is_deterministic
    # Create a variable for each possible from state / read symbol pair.
    # From_st ^ Read_sy -> TransitionPair_st_sy
    variables = transitions.times do |transition|
      state_vars("From", transition).each.with_index do |from_state, i|
        symbol_vars("Read", transition).each.with_index do |read_symbol, j|
          variable = "TransitionPair_#{transition}_#{i}_#{j}"
          io.puts "-#{from_state} -#{read_symbol} #{variable}"
        end
      end
    end

    # There must be one of each pairing across all transitions.
    states.times do |state|
      symbols.times do |symbol|
        variables = transitions.times.map do |transition|
          "TransitionPair_#{transition}_#{state}_#{symbol}"
        end
        CommanderVariable.exactly_one(variables, io)
      end
    end
  end

  def state_vars(prefix, transition)
    states.times.map do |state|
      "#{prefix}_#{transition}_#{state}"
    end
  end

  def symbol_vars(prefix, transition)
    symbols.times.map do |symbol|
      "#{prefix}_#{transition}_#{symbol}"
    end
  end
end
