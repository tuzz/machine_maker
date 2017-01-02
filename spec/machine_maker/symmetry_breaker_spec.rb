RSpec.describe SymmetryBreaker do
  it "imposes a canonical order on sets to break symmetric solutions" do
    cnf = StringIO.new

    pidgeons = 31.times.map { |i| "Pidgeon_#{i}" }
    holes = 30.times.map { |i| "Hole_#{i}" }

    # Every pidgeon must be in at least one hole.
    pidgeon_holes = pidgeons.map do |pidgeon|
      variables = holes.map { |hole| "#{pidgeon}_#{hole}" }
      cnf.puts variables.join(" ")
      variables
    end

    # No two pidgeons can be in the same hole.
    holes.each do |hole|
      pidgeons.combination(2) do |a, b|
        cnf.puts "-#{a}_#{hole} -#{b}_#{hole}"
      end
    end

    # Break symmetries.
    subject.canonically_order(pidgeon_holes, cnf)

    dimacs = StringIO.new
    DimacsWriter.write(cnf, dimacs, remember: true)

    certificate = StringIO.new

    # Lingeling does symmetry breaking, so use a different solver:
    SatSolver.solve(dimacs, certificate, command: "riss")

    time_taken = Benchmark.realtime do
      result = CertificateDecoder.decode(certificate, dimacs)
      expect(result).to be_nil
    end

    expect(time_taken).to be < 0.5
  end
end
