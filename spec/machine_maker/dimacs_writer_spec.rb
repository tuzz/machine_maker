RSpec.describe DimacsWriter do
  let(:input) { StringIO.new }
  let(:output) { StringIO.new }

  let(:dimacs) { output.string.split("\n") }

  it "writes dimacs for some input variables" do
    input.puts "a b -c"
    input.puts "-a c"
    input.puts "-b c"
    input.puts "c"

    DimacsWriter.write(input, output)

    expect(dimacs).to eq [
      "p cnf 3 4",
      "1 2 -3 0",
      "-1 3 0",
      "-2 3 0",
      "3 0",
    ]
  end

  it "raises an error if a double-negation is detected" do
    input.puts "--a"

    expect {
      DimacsWriter.write(input, output)
    }.to raise_error(/double negation: --a/)
  end

  it "can remember which variables map to literals" do
    input.puts "a b c"
    input.puts "a -d b"

    DimacsWriter.write(input, output, remember: %w(b d))

    expect(dimacs).to eq [
      "p cnf 4 2",
      "1 2 3 0",
      "1 -4 2 0",
      "c 2 b",
      "c 4 d",
    ]
  end

  it "can remember everything" do
    input.puts "a b c"
    input.puts "a -d b"

    DimacsWriter.write(input, output, remember: true)

    expect(dimacs).to eq [
      "p cnf 4 2",
      "1 2 3 0",
      "1 -4 2 0",
      "c 1 a",
      "c 2 b",
      "c 3 c",
      "c 4 d",
    ]
  end
end
