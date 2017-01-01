RSpec.describe LessThan do
  def less_than(a, b)
    bits = Math.log2([a, b].max + 1).ceil

    a_bits = bits.times.map { |j| "a#{j}" }
    b_bits = bits.times.map { |j| "b#{j}" }

    cnf = StringIO.new
    subject.write(a_bits, b_bits, cnf)

    encode_number(a, a_bits, cnf)
    encode_number(b, b_bits, cnf)

    dimacs = StringIO.new
    DimacsWriter.write(cnf, dimacs, remember: true)

    certificate = StringIO.new
    SatSolver.solve(dimacs, certificate, stderr: $stderr)

    !!CertificateDecoder.decode(certificate, dimacs)
  end

  def encode_number(x, bits, cnf)
    binary = x.to_s(2).rjust(bits.size, "0")

    binary.chars.each.with_index do |char, i|
      cnf.puts "#{"-" if char == "0"}#{bits[i]}"
    end
  end

  it "writes cnf that forces a to be less than b" do
    1.upto(9) do |a|
      1.upto(9) do |b|
        expect(less_than(a, b)).to eq(a < b), "#{a}, #{b}"
      end
    end
  end
end
