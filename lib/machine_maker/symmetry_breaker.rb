# See: http://cstheory.stackexchange.com/questions/17139/how-do-i-use-canonical-ordering-to-reduce-symmetry-in-the-sat-encoding-of-the-pi

# Note: Lingeling already breaks some symmetries so this might not actually help
# See: http://fmv.jku.at/papers/Biere-SAT-Competition-2013-TPH-problem.pdf

module SymmetryBreaker
  class << self
    def canonically_order(set, io)
      num_bits = Math.log2(set.first.size).ceil

      numbers = set.map do |member|
        number = num_bits.times.map { var_alloc }

        number.each.with_index do |bit, i|
          exponent = num_bits - i - 1

          variables = member
            .each_slice(2 ** exponent)
            .with_index
            .select { |slice, i| i.odd? }
            .map(&:first)
            .flatten

          variables << "-#{bit}"

          CommanderVariable.exactly_one(variables, io)
        end

        number
      end

      numbers.each_cons(2) do |smaller, bigger|
        LessThan.write(smaller, bigger, io)
      end
    end

    def var_alloc(hint = nil)
      "Sym#{hint}_#{counter.next}"
    end

    def counter
      @counter ||= Counter.new
    end
  end
end
