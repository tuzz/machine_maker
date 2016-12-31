module CertificateDecoder
  class << self
    def decode(certificate, dimacs)
      metadata = parse_metadata(dimacs)
      parse_certificate(certificate, metadata)
    end

    def parse_metadata(dimacs)
      dimacs.rewind

      dimacs.each_line.with_object({}) do |line, hash|
        next unless line.start_with?("c")

        literal, variable = line[2..-1].split(" ")
        hash[literal] = variable
      end
    end

    def parse_certificate(certificate, metadata)
      certificate.rewind

      hash = {}
      certificate.each_line do |line|
        return nil if line.start_with?("s UNSAT")
        next unless line.start_with?("v")

        literals = line[2..-1].split(" ")
        literals.each do |literal|
          if literal.start_with?("-")
            lookup = literal[1..-1]
            positive = false
          else
            lookup = literal
            positive = true
          end

          variable = metadata[lookup]
          next unless variable

          hash[variable] = positive
        end
      end

      hash
    end
  end
end
