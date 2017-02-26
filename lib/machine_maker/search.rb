class Search
  DEFAULT_ALPHABET = %w(0 1 _)

  attr_accessor(
    :expectations,
    :computation,
    :alphabet,
    :states,
    :symbols,
    :transitions,
    :steps_fn,
    :io,
    :dimacs,
    :certificate,
    :raw_result,
    :result
  )

  def initialize
    self.expectations = []
    self.computation = 0
    self.alphabet = DEFAULT_ALPHABET
    self.states = 1
    self.transitions = 1
    self.steps_fn = -> (_) { 1 }
    self.symbols = self.alphabet.size
  end

  def expect(input:, output:, start: nil, stop: nil)
    expectations.push(
      input: input,
      output: output,
      start: start,
      stop: stop,
    )
  end

  def alphabet=(alphabet)
    @alphabet = alphabet
    self.io = nil
  end

  def states=(states)
    @states = states
    self.io = nil
  end

  def symbols=(symbols)
    @symbols = symbols
    self.io = nil
  end

  def transitions=(transitions)
    @transitions = transitions
    self.io = nil
  end

  def steps_fn=(steps_fn)
    @steps_fn = steps_fn
    self.io = nil
  end

  def execute
		check_symbol_count
    reduce_to_cnf
    write_dimacs
    sat_solve
    decode_result
    interpret_result
  end

  def transition_rules
    result.transition_rules if result
  end

  def head_positions
    result.head_positions if result
  end

  private

	def check_symbol_count
    unless symbols >= alphabet.size
      raise ArgumentError, "Symbols must be >= size of the alphabet"
    end
	end

  def reduce_to_cnf
    unless io
      self.io = StringIO.new
      reduce_description
    end

    computation.upto(expectations.length - 1) do
      reduce_expectation
      reduce_computation
    end

    computation = expectations.length
  end

  def write_dimacs
    self.dimacs = StringIO.new
    DimacsWriter.write(io, dimacs, remember: true)
  end

  def sat_solve
    self.certificate = StringIO.new
    SatSolver.solve(dimacs, certificate)
  end

  def decode_result
    self.raw_result = CertificateDecoder.decode(certificate, dimacs)
  end

  def interpret_result
    if raw_result
      self.result = ResultInterpreter.new(raw_result, alphabet: alphabet)
    else
      self.result = nil
    end
  end

  def reduce_description
    DescriptionReducer.new(
      symbols: symbols,
      states: states,
      transitions: transitions,
      break_symmetries: false,
      io: io,
    ).reduce
  end

  def reduce_expectation
    ex = expectations[computation]

    ExpectationReducer.new(
      alphabet: alphabet,
      input: ex.fetch(:input),
      output: ex.fetch(:output),
      computation: computation,
      steps: steps_fn.call(ex),
      start: ex.fetch(:start),
      stop: ex.fetch(:stop),
      io: io,
    ).reduce
  end

  def reduce_computation
    ex = expectations[computation]

    ComputationReducer.new(
      computation: computation,
      steps: steps_fn.call(ex),
      symbols: symbols,
      states: states,
      cells: ex.fetch(:input).length,
      transitions: transitions,
      io: io,
    ).reduce

    self.computation += 1
  end
end
