module SatSolver
  class << self
    def solve(dimacs, certificate, stderr: nil, command: "lingeling")
      dimacs.rewind

      Open3.popen3(command) do |input, out, err|
        dimacs.each_line { |l| input.puts(l) }
        input.close_write

        out.read.each_line { |l| certificate.puts(l) }
        err.read.each_line { |l| stderr.puts(l) } if stderr
      end
    end
  end
end
