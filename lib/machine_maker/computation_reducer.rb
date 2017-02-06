class ComputationReducer
  def self.reduce(**params)
    new(**params).reduce
  end

  attr_accessor :computation, :steps, :symbols, :states, :cells, :transitions, :io

  def initialize(computation:, steps:, symbols:, states:, cells:, transitions:, io:)
    self.computation = computation
    self.steps = steps
    self.symbols = symbols
    self.states = states
    self.cells = cells
    self.transitions = transitions
    self.io = io
  end

  def reduce
    reduce_configurations
    reduce_steps
    reduce_connections
  end

  def reduce_configurations
    (steps + 1).times do |step|
      ConfigurationReducer.new(
        computation: computation,
        step: step,
        symbols: symbols,
        states: states,
        cells: cells,
        io: io,
      ).reduce
    end
  end

  def reduce_steps
    steps.times do |step|
      StepReducer.new(
        computation: computation,
        step: step,
        transitions: transitions,
        symbols: symbols,
        states: states,
        io: io,
      ).reduce
    end
  end

  def reduce_connections
    steps.times do |step|
      ConnectionReducer.new(
        computation: computation,
        step: step,
        symbols: symbols,
        states: states,
        cells: cells,
        io: io,
      ).reduce
    end
  end
end
