RSpec.describe ConfigurationReducer do
  let(:io) { StringIO.new }
  let(:dimacs) { io.string.split("\n") }

  subject do
    described_class.new(
      computation: 1,
      step: 2,
      symbols: 3,
      states: 4,
      cells: 5,
      io: io,
    )
  end

  describe "#head_is_in_one_place" do
    it "uses commander variable" do
      subject.head_is_in_one_place

      expect(dimacs).to include(
        "Head_1_2_0 Head_1_2_1 Head_1_2_2 -Com_1",
      )
    end
  end

  describe "#each_tape_cell_contains_one_symbol" do
    it "uses commander variable" do
      subject.each_tape_cell_contains_one_symbol

      expect(dimacs).to include(
        "-Tape_1_2_0_0 -Tape_1_2_0_1",
      )
    end
  end

  describe "#in_one_state" do
    it "uses commander variable" do
      subject.in_one_state

      expect(dimacs).to include(
        "State_1_2_0 State_1_2_1 State_1_2_2 -Com_1",
      )
    end
  end

  describe "#reads_one_symbol" do
    it "uses commander variable" do
      subject.reads_one_symbol

      expect(dimacs).to include(
        "-Symbol_1_2_0 -Symbol_1_2_1",
      )
    end

    it "is a consequence of the head and tape symbols" do
      subject.reads_one_symbol

      # If the head is at position 0 and the tape contents of the 0 cell are 1
      # then the read symbol must be a 1.
      expect(dimacs).to include(
        "-Head_1_2_0 -Tape_1_2_0_1 Symbol_1_2_1",
      )
    end
  end

  describe "integration" do
    let(:dimacs) { StringIO.new }
    let(:certificate) { StringIO.new }

    let(:result) do
      subject.reduce

      DimacsWriter.write(subject.io, dimacs, remember: true)
      SatSolver.solve(dimacs, certificate)
      CertificateDecoder.decode(certificate, dimacs)
    end

    let(:head_positions) do
      result.values_at(
        "Head_1_2_0",
        "Head_1_2_1",
        "Head_1_2_2",
        "Head_1_2_3",
        "Head_1_2_4",
      )
    end

    let(:read_symbols) do
      result.values_at(
        "Symbol_1_2_0",
        "Symbol_1_2_1",
        "Symbol_1_2_2",
      )
    end

    it "has exactly one head position" do
      expect(head_positions).to be_one
    end

    it "has exactly one symbol on a tape cell" do
      symbols = result.values_at(
        "Tape_1_2_3_0",
        "Tape_1_2_3_1",
        "Tape_1_2_3_2",
      )

      expect(symbols).to be_one
    end

    it "is in exactly one state" do
      states = result.values_at(
        "State_1_2_0",
        "State_1_2_1",
        "State_1_2_2",
        "State_1_2_3",
      )

      expect(states).to be_one
    end

    it "has exactly one read symbol" do
      expect(read_symbols).to be_one
    end

    it "has a read symbol that matches the tape and head position" do
      position = head_positions.index(true)

      tape_symbols = result.values_at(
        "Tape_1_2_#{position}_0",
        "Tape_1_2_#{position}_1",
        "Tape_1_2_#{position}_2",
      )

      expect(read_symbols).to eq(tape_symbols)
    end
  end
end
