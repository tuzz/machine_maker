require "rspec"
require "pry"
require "machine_maker"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.color = true
  config.formatter = :doc
end
