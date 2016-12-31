class Counter
  attr_accessor :count

  def initialize
    reset!
  end

  def reset!
    self.count = 0
  end

  def next
    self.count += 1
  end
end
