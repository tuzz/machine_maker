RSpec.describe ConnectionReducer do
  let(:io) { StringIO.new }
  let(:dimacs) { io.string.split("\n") }
  let(:transitions) { 2 }

  subject do
    described_class.new(
      computation: 0,
      step: 1,
      symbols: 2,
      states: 3,
      cells: 4,
      io: io,
    )
  end

  describe "#previous_state_equals_from" do
    it "ensures the configuration's and step's states are equal" do
      subject.previous_state_equals_from

      expect(dimacs).to include(
        "-State_0_1_0 Step_0_1_From_0",
        "State_0_1_0 -Step_0_1_From_0",

        "-State_0_1_2 Step_0_1_From_2",
        "State_0_1_2 -Step_0_1_From_2",
      )
    end
  end

  describe "#next_state_equals_to" do
    it "ensures the configuration's and step's states are equal" do
      subject.next_state_equals_to

      expect(dimacs).to include(
        "-State_0_2_0 Step_0_1_To_0",
        "State_0_2_0 -Step_0_1_To_0",

        "-State_0_2_2 Step_0_1_To_2",
        "State_0_2_2 -Step_0_1_To_2",
      )
    end
  end

  describe "#previous_read_equals_read" do
    it "ensures the configuration's read symbol and step's read symbol are equal" do
      subject.previous_read_equals_read

      expect(dimacs).to include(
        "-Symbol_0_1_0 Step_0_1_Read_0",
        "Symbol_0_1_0 -Step_0_1_Read_0",

        "-Symbol_0_1_1 Step_0_1_Read_1",
        "Symbol_0_1_1 -Step_0_1_Read_1",
      )
    end
  end

  describe "#head_moves_left_if_moved_left" do
    it "ensures the head moves left from the previous head position" do
      subject.head_moves_left_if_moved_left

      expect(dimacs).to include(
        "-Step_0_1_Direction -Head_0_1_1 Head_0_2_0",
        "-Step_0_1_Direction Head_0_1_1 -Head_0_2_0",
      )

      expect(dimacs).not_to include(
        "-Step_0_1_Direction -Head_0_1_0 Head_0_2_-1",
        "-Step_0_1_Direction Head_0_1_0 -Head_0_2_-1",
      )
    end

    it "ensures the head does not move left if at left edge" do
      subject.head_moves_left_if_moved_left

      expect(dimacs).to include(
        "-Head_0_1_0 -Step_0_1_Direction"
      )
    end
  end

  describe "#head_moves_right_if_moved_right" do
    it "ensures the head moves right from the previous head position" do
      subject.head_moves_right_if_moved_right

      expect(dimacs).to include(
        "Step_0_1_Direction -Head_0_1_0 Head_0_2_1",
        "Step_0_1_Direction Head_0_1_0 -Head_0_2_1",
      )

      expect(dimacs).not_to include(
        "-Step_0_1_Direction -Head_0_1_3 Head_0_1_4",
        "-Step_0_1_Direction Head_0_1_3 -Head_0_1_4",
      )
    end

    it "ensures the head does not move right if at right edge" do
      subject.head_moves_right_if_moved_right

      expect(dimacs).to include(
        "-Head_0_1_3 Step_0_1_Direction"
      )
    end
  end

  describe "#next_right_equals_write_if_moved_left" do
    it "ensures the configuration's right symbol equals write if direction=left" do
      subject.next_right_equals_write_if_moved_left

      expect(dimacs).to include(
        "-Step_0_1_Direction -RightSymbol_0_1_0 Step_0_1_Write_0",
        "-Step_0_1_Direction RightSymbol_0_1_0 -Step_0_1_Write_0",

        "-Step_0_1_Direction -RightSymbol_0_1_1 Step_0_1_Write_1",
        "-Step_0_1_Direction RightSymbol_0_1_1 -Step_0_1_Write_1",
      )
    end
  end

  describe "#next_left_equals_write_if_moved_right" do
    it "ensures the configuration's left symbol equals write if direction=right" do
      subject.next_left_equals_write_if_moved_right

      expect(dimacs).to include(
        "Step_0_1_Direction -LeftSymbol_0_1_0 Step_0_1_Write_0",
        "Step_0_1_Direction LeftSymbol_0_1_0 -Step_0_1_Write_0",

        "Step_0_1_Direction -LeftSymbol_0_1_1 Step_0_1_Write_1",
        "Step_0_1_Direction LeftSymbol_0_1_1 -Step_0_1_Write_1",
      )
    end
  end

  describe "integration" do
    let(:dimacs) { StringIO.new }
    let(:certificate) { StringIO.new }

    before do
      StepReducer.new(
        computation: subject.computation,
        step: subject.step,
        symbols: subject.symbols,
        states: subject.states,
        io: subject.io,
        transitions: 2,
      ).reduce

      ConfigurationReducer.new(
        computation: subject.computation,
        step: subject.step,
        symbols: subject.symbols,
        states: subject.states,
        cells: subject.cells,
        io: subject.io,
      ).reduce

      ConfigurationReducer.new(
        computation: subject.computation,
        step: subject.step + 1,
        symbols: subject.symbols,
        states: subject.states,
        cells: 5,
        io: subject.io,
      ).reduce
    end

    let(:result) do
      subject.reduce

      DimacsWriter.write(subject.io, dimacs, remember: true)
      SatSolver.solve(dimacs, certificate)
      CertificateDecoder.decode(certificate, dimacs)
    end

    let(:previous_state) do
      result.values_at(
        "State_0_1_0",
        "State_0_1_1",
        "State_0_1_2",
      )
    end

    let(:next_state) do
      result.values_at(
        "State_0_2_0",
        "State_0_2_1",
        "State_0_2_2",
      )
    end

    let(:previous_symbol) do
      result.values_at(
        "Symbol_0_1_0",
        "Symbol_0_1_1",
        "Symbol_0_1_2",
      )
    end

    let(:step_from_state) do
      result.values_at(
        "Step_0_1_From_0",
        "Step_0_1_From_1",
        "Step_0_1_From_2",
      )
    end

    let(:step_to_state) do
      result.values_at(
        "Step_0_1_To_0",
        "Step_0_1_To_1",
        "Step_0_1_To_2",
      )
    end

    let(:step_read_symbol) do
      result.values_at(
        "Step_0_1_Read_0",
        "Step_0_1_Read_1",
        "Step_0_1_Read_2",
      )
    end

    it "makes previous state equal to the step's from state" do
      expect(previous_state).to eq(step_from_state)
    end

    it "makes next state equal to the step's to state" do
      expect(next_state).to eq(step_to_state)
    end

    it "makes previous symbol equal to the step's read symbol" do
      expect(previous_symbol).to eq(step_read_symbol)
    end

    context "when the head was at position 2" do
      before do
        io.puts "Head_0_1_2"
      end

      context "and the head moves left" do
        before do
          io.puts "Step_0_1_Direction"
        end

        it "sets the next head position as cell 1" do
          expect(result["Head_0_2_1"]).to eq(true)
        end

        it "writes the write symbol to the right cell in the next configuration" do
          write_symbol = result.values_at(
            "Step_0_1_Write_0",
            "Step_0_1_Write_1",
          )

          right_symbol = result.values_at(
            "RightSymbol_0_1_0",
            "RightSymbol_0_1_1",
          )

          expect(write_symbol).to eq(right_symbol)
        end
      end

      context "and the head moves right" do
        before do
          io.puts "-Step_0_1_Direction"
        end

        it "sets the next head position as cell 3" do
          expect(result["Head_0_2_3"]).to eq(true)
        end

        it "writes the write symbol to the left cell in the next configuration" do
          write_symbol = result.values_at(
            "Step_0_1_Write_0",
            "Step_0_1_Write_1",
          )

          left_symbol = result.values_at(
            "LeftSymbol_0_1_0",
            "LeftSymbol_0_1_1",
          )

          expect(write_symbol).to eq(left_symbol)
        end
      end
    end

    context "when the head was at the left edge" do
      before do
        io.puts "Head_0_1_0"
      end

      it "cannot move left" do
        io.puts "Step_0_1_Direction"
        expect(result).to be_nil
      end

      it "chooses to move right" do
        expect(result["Step_0_1_Direction"]).to eq(false)
      end
    end

    context "when the head was at the right edge" do
      before do
        io.puts "Head_0_1_3"
      end

      it "cannot move right" do
        io.puts "-Step_0_1_Direction"
        expect(result).to be_nil
      end

      it "chooses to move left" do
        expect(result["Step_0_1_Direction"]).to eq(true)
      end
    end
  end
end
