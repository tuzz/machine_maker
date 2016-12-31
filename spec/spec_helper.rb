require "rspec"
require "benchmark"
require "pry"
require "machine_maker"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.color = true
  config.formatter = :doc

  config.before(:each) do
    CommanderVariable.counter.reset!
  end
end
