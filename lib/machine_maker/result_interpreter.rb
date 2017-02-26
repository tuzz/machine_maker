class ResultInterpreter
  DEFAULT_ALPHABET = %w(0 1 _)

  attr_accessor :result, :alphabet

  def initialize(result, alphabet: nil)
    self.result = result
    self.alphabet = alphabet || DEFAULT_ALPHABET
  end

  def transition_rules
    return unless result

    from = extract("From")
    read = lookup_symbols(extract("Read"))
    write = lookup_symbols(extract("Write"))
    direction = filter("Direction").values.map { |v| v ? :L : :R }
    to = extract("To")

    from.zip(read, write, direction, to).sort
  end

  def head_positions
    return unless result

    true_keys("Head")
      .map { |s| s.split("_") }
      .group_by { |_, computation, _, _| computation }
      .values
      .map { |arr| arr.map { |_, _, _, cell| cell.to_i } }
  end

  private

  def extract(type)
    true_keys(type).map { |s| s.split("_").last.to_i }
  end

  def true_keys(type)
    filter(type).select { |_, v| v }.keys
  end

  def filter(type)
    result.select { |k, _| k.start_with?(type) }
  end

  def lookup_symbols(array)
    array.map { |i| alphabet[i] }
  end
end
