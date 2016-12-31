module DimacsWriter
  class << self
    def write(input, output, remember: [])
      first_pass(input, output)
      second_pass(input, output)
      write_metadata(remember, output)
    end

    def first_pass(input, output)
      input.rewind

      clauses = 0
      literals = 0

      counter = Counter.new
      @mappings = {}

      input.each_line do |line|
        clauses += 1
        line.gsub("-", "").split(" ").each do |variable|
          next if @mappings[variable]

          @mappings[variable] = counter.next
          literals += 1
        end
      end

      output.puts "p cnf #{literals} #{clauses}"
    end

    def second_pass(input, output)
      input.rewind

      input.each_line do |line|
        line.split(" ").each do |variable|
          if variable.start_with?("-")
            lookup = variable[1..-1]
            negative = true

            raise "double negation: #{line}" if lookup.start_with?("-")
          else
            lookup = variable
          end

          literal = @mappings[lookup]
          output.print "#{ "-" if negative }#{literal} "
        end

        output.puts "0"
      end
    end

    def write_metadata(variables, output)
      variables.each do |variable|
        literal = @mappings[variable]
        output.puts "c #{literal} #{variable}"
      end
    end
  end
end
