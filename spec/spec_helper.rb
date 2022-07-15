require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'bundler/setup'
require 'aliyun/opensearch'
require 'active_support/testing/time_helpers'
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # add travel_to
  config.include ActiveSupport::Testing::TimeHelpers

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
