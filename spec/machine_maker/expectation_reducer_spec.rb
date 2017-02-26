RSpec.describe ExpectationReducer do
  let(:io) { StringIO.new }
  let(:dimacs) { io.string.split("\n") }
  let(:start) { nil }
  let(:stop) { nil }

  subject do
    described_class.new(
      input: "__01101___",
      output: "__01110___",
      start: start,
      stop: stop,
      computation: 1,
      steps: 5,
      io: io,
    )
  end

  it "ensures the initial tape matches the input" do
    subject.initial_tape_matches_input

    expect(dimacs).to eq %w(
      Tape_1_0_0_2
      Tape_1_0_1_2
      Tape_1_0_2_0
      Tape_1_0_3_1
      Tape_1_0_4_1
      Tape_1_0_5_0
      Tape_1_0_6_1
      Tape_1_0_7_2
      Tape_1_0_8_2
      Tape_1_0_9_2
    )
  end

  it "ensures the final tape matches the output" do
    subject.final_tape_matches_output

    expect(dimacs).to eq %w(
      Tape_1_5_0_2
      Tape_1_5_1_2
      Tape_1_5_2_0
      Tape_1_5_3_1
      Tape_1_5_4_1
      Tape_1_5_5_1
      Tape_1_5_6_0
      Tape_1_5_7_2
      Tape_1_5_8_2
      Tape_1_5_9_2
    )
  end

  it "raises an error if the input and output sizes differ" do
    expect {
      described_class.new(
        input: "__01101__",
        output: "__01110___",
        computation: 1,
        steps: 5,
        io: io,
      )
    }.to raise_error(ArgumentError)
  end

  it "can use a custom alphabet" do
    described_class.new(
      alphabet: %w(x A B C),
      input: "xxABCxx",
      output: "xxCBAxx",
      computation: 1,
      steps: 5,
      io: io,
    ).reduce

    expect(dimacs).to include(
      "Tape_1_0_0_0",
      "Tape_1_0_1_0",
      "Tape_1_0_2_1",
      "Tape_1_0_3_2",

      "Tape_1_5_0_0",
      "Tape_1_5_1_0",
      "Tape_1_5_2_3",
      "Tape_1_5_3_2",
    )
  end

  it "can pass arrays as input and output" do
    described_class.new(
      alphabet: %w(x A B C),
      input: %w(x x A B C x x),
      output: %w(x x C B A x x),
      computation: 1,
      steps: 5,
      io: io,
    ).reduce

    expect(dimacs).to include(
      "Tape_1_0_1_0",
      "Tape_1_0_2_1",
      "Tape_1_5_1_0",
      "Tape_1_5_2_3",
    )
  end

  it "does not set head start/stop positions if not specified" do
    subject.head_start_position_is_set
    subject.head_stop_position_is_set

    expect(dimacs).to be_empty
  end

  context "when start and stop head positions are set" do
    let(:start) { 3 }
    let(:stop) { 4 }

    it "ensures the head start position is set" do
      subject.head_start_position_is_set
      expect(dimacs).to eq(%w(Head_1_0_3))
    end

    it "ensures the head stop position is set" do
      subject.head_stop_position_is_set
      expect(dimacs).to eq(%w(Head_1_5_4))
    end
  end
end
