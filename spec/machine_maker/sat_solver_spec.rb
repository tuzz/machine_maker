RSpec.describe SatSolver do
  let(:dimacs) do
    io = StringIO.new

    io.puts "p cnf 3 4"
    io.puts "-1 -2 3 0"
    io.puts "1 -3 0"
    io.puts "2 -3 0"
    io.puts "3 0"

    io
  end

  let(:output) { StringIO.new }
  let(:certificate) { output.string.split("\n") }

  it "solves a sat problem in dimacs form" do
    subject.solve(dimacs, output)

    expect(certificate).to include("c Lingeling SAT Solver")
    expect(certificate).to include("s SATISFIABLE")
    expect(certificate).to include("v 1 2 3 0")
  end

  it "can optionally return standard error" do
    dimacs = StringIO.new
    error = StringIO.new

    dimacs.puts "invalid"

    subject.solve(dimacs, output, stderr: error)
    expect(error.string).to eq("<stdin>:1: missing 'p ...' header\n")
  end
end
