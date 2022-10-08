# frozen_string_literal: true

require "bots"

RSpec.configure do |config|
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.default_formatter = :doc
end
