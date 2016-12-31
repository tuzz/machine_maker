RSpec.describe CertificateDecoder do
  let(:certificate) do
    io = StringIO.new

    io.puts "c foo"
    io.puts "s SATISFIABLE"
    io.puts "v 1 -2 3 -4 5 -6 7 -8 0"
    io.puts "v 9 10 11 12 13 -14 -15 0"
    io.puts "v 0"

    io
  end

  let(:dimacs) do
    io = StringIO.new

    io.puts "p cnf 123 123"
    io.puts "1 2 3 0"
    io.puts "-1 3 0"
    io.puts "c 7 a"
    io.puts "c 15 H_0_0_15"

    io
  end

  it "decodes the certificate according to the metadata" do
    result = subject.decode(certificate, dimacs)
    expect(result).to eq("a" => true, "H_0_0_15" => false)
  end

  it "returns nil if the problem is unsatisfiable" do
    unsat = StringIO.new

    unsat.puts "c foo"
    unsat.puts "s UNSATISFIABLE"

    result = subject.decode(unsat, dimacs)
    expect(result).to be_nil
  end
end
