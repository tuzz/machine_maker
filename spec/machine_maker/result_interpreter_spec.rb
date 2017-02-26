RSpec.describe ResultInterpreter do
  let(:io) { StringIO.new }
  let(:dimacs) { StringIO.new }
  let(:certificate) { StringIO.new }

  let(:computation) { 1 }
  let(:symbols) { 3 }
  let(:states) { 4 }
  let(:transitions) { 5 }
  let(:cells) { 10 }
  let(:steps) { 8 }
  let(:start) { 3 }
  let(:stop) { 5 }

  before do
    DescriptionReducer.new(
      symbols: symbols,
      states: states,
      transitions: transitions,
      break_symmetries: false,
      io: io,
    ).reduce

    ComputationReducer.new(
      computation: computation,
      steps: steps,
      symbols: symbols,
      states: states,
      cells: cells,
      transitions: transitions,
      io: io,
    ).reduce

    ExpectationReducer.new(
      input: "___111____",
      output: "__1000____",
      computation: computation,
      steps: steps,
      start: start,
      stop: stop,
      io: io,
    ).reduce
  end

  let(:result) do
    DimacsWriter.write(io, dimacs, remember: true)
    SatSolver.solve(dimacs, certificate)
    CertificateDecoder.decode(certificate, dimacs)
  end

  subject { described_class.new(result) }

  it "interprets the machine description from the result" do
    expect(subject.transition_rules).to eq [
			[0, "1", "1", :R, 1],
			[1, "1", "1", :L, 1],
			[1, "_", "1", :R, 2],
			[2, "1", "0", :R, 2],
			[2, "_", "_", :L, 3],
		]
  end

  it "interprets start/stop head positions per computation" do
    expect(subject.head_positions).to eq [
      [3, 4, 3, 2, 3, 4, 5, 6, 5],
    ]
  end

	context "when there is no solution" do
    let(:states) { 1 }

    it "returns nil" do
      expect(subject.transition_rules).to be_nil
      expect(subject.head_positions).to be_nil
    end
	end
end
