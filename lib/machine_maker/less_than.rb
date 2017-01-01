module LessThan
  class << self
    def write(a, b, io)
      less_thans = less_thans(a, b, io)
      equals = equals(a, b, io)

      variables = less_thans.zip(equals).map do |less_than, equal|
        if equal
          bit_and(less_than, equal, io)
        else
          less_than
        end
      end

      io.puts variables.join(" ")
    end

    def less_thans(a, b, io)
      a.zip(b).map do |a_bit, b_bit|
        bit_less_than(a_bit, b_bit, io)
      end
    end

    def equals(a, b, io)
      equals = [nil]

      a.zip(b)[0..-2].each do |a_bit, b_bit|
        equal = bit_equal(a_bit, b_bit, io)
        previous = equals.last
        equal = bit_and(previous, equal, io) if previous
        equals.push(equal)
      end

      equals
    end

    def bit_less_than(a, b, io)
      c = var_alloc

      io.puts "-#{a} -#{c}"
      io.puts "#{a} -#{b} #{c}"
      io.puts "#{a} #{b} -#{c}"

      c
    end

    def bit_equal(a, b, io)
      c = var_alloc

      io.puts "#{a} #{b} #{c}"
      io.puts "#{a} -#{b} -#{c}"
      io.puts "-#{a} #{b} -#{c}"
      io.puts "-#{a} -#{b} #{c}"

      c
    end

    def bit_and(a, b, io)
      c = var_alloc

      io.puts "-#{a} -#{b} #{c}"
      io.puts "#{a} -#{c}"
      io.puts "#{b} -#{c}"

      c
    end

    def var_alloc
      "LessThan_#{counter.next}"
    end

    def counter
      @counter ||= Counter.new
    end
  end
end
