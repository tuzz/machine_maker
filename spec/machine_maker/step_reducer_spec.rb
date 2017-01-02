RSpec.describe StepReducer do
  let(:io) { StringIO.new }
  let(:dimacs) { io.string.split("\n") }

  subject do
    described_class.new(
      computation: 0,
      step: 1,
      transitions: 2,
      symbols: 3,
      states: 4,
      io: io,
    )
  end

  describe "#follows_one_transition" do
    it "uses commander variable" do
      subject.follows_one_transition

      expect(dimacs).to eq [ "StepTran_0_1_0 StepTran_0_1_1",
        "-StepTran_0_1_0 -StepTran_0_1_1",
      ]
    end
  end

  describe "#denormalise_transition_from_state" do
    it "uses commander variable" do
      subject.denormalise_transition_from_state

      expect(dimacs).to include(
        "-Step_0_1_From_0 -Step_0_1_From_1",
      )
    end

    it "is implied by the transition and its from state" do
      subject.denormalise_transition_from_state

      # If transition 0 is chosen and that transition's from state is 1 then the
      # step's from state must be 1.
      expect(dimacs).to include(
        "-StepTran_0_1_0 -From_0_1 Step_0_1_From_1",
      )
    end
  end

  describe "#denormalise_transition_to_state" do
    it "uses commander variable" do
      subject.denormalise_transition_to_state

      expect(dimacs).to include(
        "-Step_0_1_To_0 -Step_0_1_To_1",
      )
    end

    it "is implied by the transition and its to state" do
      subject.denormalise_transition_to_state

      # If transition 1 is chosen and that transition's to state is 0 then the
      # step's to state must be 0.
      expect(dimacs).to include(
        "-StepTran_0_1_1 -To_1_0 Step_0_1_To_0",
      )
    end
  end

  describe "#denormalise_transition_read_symbol" do
    it "uses commander variable" do
      subject.denormalise_transition_read_symbol

      expect(dimacs).to include(
        "-Step_0_1_Read_0 -Step_0_1_Read_1",
      )
    end

    it "is implied by the transition and its read symbol" do
      subject.denormalise_transition_read_symbol

      # If transition 0 is chosen and that transition's read symbol is 1 then
      # the step's read symbol must be 1.
      expect(dimacs).to include(
        "-StepTran_0_1_0 -Read_0_1 Step_0_1_Read_1",
      )
    end
  end

  describe "#denormalise_transition_write_symbol" do
    it "uses commander variable" do
      subject.denormalise_transition_write_symbol

      expect(dimacs).to include(
        "-Step_0_1_Write_0 -Step_0_1_Write_1",
      )
    end

    it "is implied by the transition and its write symbol" do
      subject.denormalise_transition_write_symbol

      # If transition 1 is chosen and that transition's write symbol is 0 then
      # the step's write symbol must be 0.
      expect(dimacs).to include(
        "-StepTran_0_1_1 -Write_1_0 Step_0_1_Write_0",
      )
    end
  end

  describe "#denormalise_transition_direction" do
    it "is implied by the transition's direction" do
      subject.denormalise_transition_direction

      # If transition 0 is chosen and that transition moves left then the step's
      # direction must be left, otherwise right.
      expect(dimacs).to include(
        "-StepTran_0_1_0 -Direction_0 Step_0_1_Direction",
        "-StepTran_0_1_0 Direction_0 -Step_0_1_Direction",
      )
    end
  end

  describe "integration" do
    let(:dimacs) { StringIO.new }
    let(:certificate) { StringIO.new }

    before do
      DescriptionReducer.new(
        transitions: subject.transitions,
        symbols: subject.symbols,
        states: subject.states,
        break_symmetries: false,
        io: subject.io,
      ).reduce
    end

    let(:result) do
      subject.reduce

      DimacsWriter.write(subject.io, dimacs, remember: true)
      SatSolver.solve(dimacs, certificate)
      CertificateDecoder.decode(certificate, dimacs)
    end

    let(:transitions) { result.values_at("StepTran_0_1_0", "StepTran_0_1_1") }
    let(:transition) { transitions.index(true) }

    it "has exactly one transition" do
      expect(transitions).to be_one
    end

    it "denormalises from state" do
      states = result.values_at(
        "Step_0_1_From_0",
        "Step_0_1_From_1",
        "Step_0_1_From_2",
        "Step_0_1_From_3",
      )

      transition_states = result.values_at(
        "From_#{transition}_0",
        "From_#{transition}_1",
        "From_#{transition}_2",
        "From_#{transition}_3",
      )

      expect(states).to eq(transition_states)
    end

    it "denormalises to state" do
      states = result.values_at(
        "Step_0_1_To_0",
        "Step_0_1_To_1",
        "Step_0_1_To_2",
        "Step_0_1_To_3",
      )

      transition_states = result.values_at(
        "To_#{transition}_0",
        "To_#{transition}_1",
        "To_#{transition}_2",
        "To_#{transition}_3",
      )

      expect(states).to eq(transition_states)
    end

    it "denormalises read symbol" do
      symbols = result.values_at(
        "Step_0_1_Read_0",
        "Step_0_1_Read_1",
        "Step_0_1_Read_2",
        "Step_0_1_Read_3",
      )

      transition_symbols = result.values_at(
        "Read_#{transition}_0",
        "Read_#{transition}_1",
        "Read_#{transition}_2",
        "Read_#{transition}_3",
      )

      expect(symbols).to eq(transition_symbols)
    end

    it "denormalises write symbol" do
      symbols = result.values_at(
        "Step_0_1_Write_0",
        "Step_0_1_Write_1",
        "Step_0_1_Write_2",
        "Step_0_1_Write_3",
      )

      transition_symbols = result.values_at(
        "Write_#{transition}_0",
        "Write_#{transition}_1",
        "Write_#{transition}_2",
        "Write_#{transition}_3",
      )

      expect(symbols).to eq(transition_symbols)
    end

    it "denormalises direction" do
      direction = result.fetch("Step_0_1_Direction")
      transition_direction = result.fetch("Direction_#{transition}")

      expect(direction).to eq(transition_direction)
    end
  end
end
