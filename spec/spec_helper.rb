# frozen_string_literal: true

require_relative 'support/shared_examples/state_space_search'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.order = :random
  Kernel.srand config.seed
end
