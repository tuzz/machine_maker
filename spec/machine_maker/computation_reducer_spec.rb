RSpec.describe ComputationReducer do
  let(:io) { StringIO.new }
  let(:dimacs) { StringIO.new }
  let(:certificate) { StringIO.new }

  subject do
    described_class.new(
      computation: 1,
      steps: 8,
      symbols: 3,
      states: 2,
      cells: 5,
      transitions: 5,
      io: io,
    )
  end

  before do
    DescriptionReducer.new(
      symbols: subject.symbols,
      states: subject.states,
      transitions: subject.transitions,
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

  it "can increment a binary number" do
    # set the initial tape to _111_ (we use 2 for _)
    io.puts "Tape_1_0_0_2"
    io.puts "Tape_1_0_1_1"
    io.puts "Tape_1_0_2_1"
    io.puts "Tape_1_0_3_1"
    io.puts "Tape_1_0_4_2"

    # position the head at the least-significant bit
    io.puts "Head_1_0_3"

    # Turing machine description:
    # 0 0 1 R 1     (a)
    # 0 1 0 L 0     (b)
    # 0 _ 1 R 1     (c)
    # 1 0 0 R 1     (d)
    # 1 _ _ L 1     (e)

    # (a)
    io.puts "From_0_0"
    io.puts "Read_0_0"
    io.puts "Write_0_1"
    io.puts "-Direction_0"
    io.puts "To_0_1"

    # (b)
    io.puts "From_1_0"
    io.puts "Read_1_1"
    io.puts "Write_1_0"
    io.puts "Direction_1"
    io.puts "To_1_0"

    # (c)
    io.puts "From_2_0"
    io.puts "Read_2_2"
    io.puts "Write_2_1"
    io.puts "-Direction_2"
    io.puts "To_2_1"

    # (d)
    io.puts "From_3_1"
    io.puts "Read_3_0"
    io.puts "Write_3_0"
    io.puts "-Direction_3"
    io.puts "To_3_1"

    # (e)
    io.puts "From_4_1"
    io.puts "Read_4_2"
    io.puts "Write_4_2"
    io.puts "Direction_4"
    io.puts "To_4_1"

    # final tape should contain 1000_
    expected_result = result.values_at(
      "Tape_1_8_0_1",
      "Tape_1_8_1_0",
      "Tape_1_8_2_0",
      "Tape_1_8_3_0",
      "Tape_1_8_4_2",
    )

    expect(expected_result).to eq [true, true, true, true, true]
  end
end
