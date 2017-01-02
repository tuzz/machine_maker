RSpec.describe DescriptionReducer do
  let(:io) { StringIO.new }
  let(:dimacs) { io.string.split("\n") }
  let(:transitions) { 2 }
  let(:break_symmetries) { false }

  subject do
    described_class.new(
      transitions: transitions,
      symbols: 3,
      states: 4,
      break_symmetries: break_symmetries,
      io: io,
    )
  end

  describe "#each_transition_goes_from_one_state" do
    it "uses commander variable" do
      subject.each_transition_goes_from_one_state

      expect(dimacs).to include(
        "From_1_0 From_1_1 From_1_2 -Com_3",
      )
    end
  end

  describe "#each_transition_goes_to_one_state" do
    it "uses commander variable" do
      subject.each_transition_goes_to_one_state

      expect(dimacs).to include(
        "To_1_0 To_1_1 To_1_2 -Com_3",
      )
    end
  end

  describe "#each_transition_reads_one_symbol" do
    it "uses commander variable" do
      subject.each_transition_reads_one_symbol

      expect(dimacs).to include(
        "-Read_1_0 -Read_1_2",
      )
    end
  end

  describe "#each_transition_writes_one_symbol" do
    it "uses commander variable" do
      subject.each_transition_writes_one_symbol

      expect(dimacs).to include(
        "-Write_1_0 -Write_1_2",
      )
    end
  end

  describe "#machine_is_deterministic" do
    it "has a variable for ever from state/read symbol pair" do
      subject.machine_is_deterministic

      expect(dimacs).to include(
        "-From_0_0 -Read_0_0 TransitionPair_0_0_0",
        "-From_0_1 -Read_0_0 TransitionPair_0_1_0",
        "-From_0_0 -Read_0_1 TransitionPair_0_0_1",
        "-From_0_1 -Read_0_1 TransitionPair_0_1_1",
        "-From_1_1 -Read_1_1 TransitionPair_1_1_1",
      )
    end

    it "uses commander-variable across pairs with the same transition" do
      subject.machine_is_deterministic

      expect(dimacs).to include(
        "TransitionPair_0_0_0 TransitionPair_1_0_0",
        "-TransitionPair_0_0_0 -TransitionPair_1_0_0",

        "TransitionPair_0_1_1 TransitionPair_1_1_1",
        "-TransitionPair_0_1_1 -TransitionPair_1_1_1",
      )

      expect(dimacs).not_to include(
        "TransitionPair_0_0_0 TransitionPair_0_0_0",
        "TransitionPair_1_0_0 TransitionPair_1_0_0",
        "TransitionPair_0_0_1 TransitionPair_1_1_0",
      )
    end
  end

  describe "integration" do
    let(:dimacs) { StringIO.new }
    let(:certificate) { StringIO.new }
    let(:transitions) { 12 }

    let(:result) do
      subject.reduce

      DimacsWriter.write(subject.io, dimacs, remember: true)
      SatSolver.solve(dimacs, certificate)
      CertificateDecoder.decode(certificate, dimacs)
    end

    it "has exactly one from state for a transition" do
      states = result.values_at(
        "From_0_0",
        "From_0_1",
        "From_0_2",
        "From_0_3",
      )

      expect(states).to be_one
    end

    it "has exactly one to state for a transition" do
      states = result.values_at(
        "To_1_0",
        "To_1_1",
        "To_1_2",
        "To_1_3",
      )

      expect(states).to be_one
    end

    it "has exactly one read symbol for a transition" do
      symbols = result.values_at(
        "Read_1_0",
        "Read_1_1",
        "Read_1_2",
        "Read_1_3",
      )

      expect(symbols).to be_one
    end

    it "has exactly one write symbol for a transition" do
      symbols = result.values_at(
        "Write_0_0",
        "Write_0_1",
        "Write_0_2",
        "Write_0_3",
      )

      expect(symbols).to be_one
    end

    let(:pairs) do
      transitions.times.map do |transition|
        from_states = result.values_at(
          "From_#{transition}_0",
          "From_#{transition}_1",
          "From_#{transition}_2",
          "From_#{transition}_3",
        )

        read_symbols = result.values_at(
          "Read_#{transition}_0",
          "Read_#{transition}_1",
          "Read_#{transition}_2",
          "Read_#{transition}_3",
        )

        [
          from_states.index(true),
          read_symbols.index(true),
        ]
      end
    end

    it "is deterministic, i.e. it has one transition per pair" do
      expect(pairs).to include(
        [0, 0], [0, 1], [0, 2],
        [1, 0], [1, 1], [1, 2],
        [2, 0], [2, 1], [2, 2],
        [3, 0], [3, 1], [3, 2],
      )
    end

    context "when break_symmetries is false" do
      let(:break_symmetries) { false }

      it "pairs do not have a canonical ordering" do
        expect(pairs).not_to eq [
          [0, 0], [0, 1], [0, 2],
          [1, 0], [1, 1], [1, 2],
          [2, 0], [2, 1], [2, 2],
          [3, 0], [3, 1], [3, 2],
        ]
      end
    end

    context "when break_symmetries is true" do
      let(:break_symmetries) { true }

      it "pairs have a canonical ordering" do
        expect(pairs).to eq [
          [0, 0], [0, 1], [0, 2],
          [1, 0], [1, 1], [1, 2],
          [2, 0], [2, 1], [2, 2],
          [3, 0], [3, 1], [3, 2],
        ]
      end
    end
  end
end
