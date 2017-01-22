# See: Efficient CNF Encoding for Selecting 1 from N Objects
# https://www.cs.cmu.edu/~wklieber/papers/2007_efficient-cnf-encoding-for-selecting-1.pdf

module CommanderVariable
  class << self
    def exactly_one(list, io)
      at_most_one(list, io, at_least_one: true)
    end

    def at_most_one(list, io, commander: nil, at_least_one: at_least_one)
      return wrapper(list, io, at_least_one: at_least_one) unless commander

      clause_vars = list.map do |item|
        if item.is_a?(Array)
          subcommander = var_alloc
          at_most_one(item, io, commander: subcommander, at_least_one: at_least_one)
          subcommander
        else
          item
        end
      end

      unless commander == 0
        clause_vars << negate(commander)
      end

      naive_at_most_one(clause_vars, io, at_least_one: at_least_one)
    end

    def wrapper(variables, io, at_least_one:)
      groups = group_vars(variables, 3)
      at_most_one(groups, io, commander: 0, at_least_one: at_least_one)
    end

    def group_vars(variables, max_size)
      if variables.size <= max_size
        variables
      else
        groups = variables.each_slice(max_size)
        group_vars(groups, max_size)
      end
    end

    def naive_at_most_one(clause_vars, io, at_least_one:)
      io.puts clause_vars.join(" ") if at_least_one

      clause_vars.combination(2).each do |(a, b)|
        io.puts "#{negate(a)} #{negate(b)}"
      end
    end

    def negate(variable)
      if variable.start_with?("-")
        variable[1..-1]
      else
        "-#{variable}"
      end
    end

    def var_alloc
      "Com_#{counter.next}"
    end

    def counter
      @counter ||= Counter.new
    end
  end
end
