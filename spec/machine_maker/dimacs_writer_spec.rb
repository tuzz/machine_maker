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
end
