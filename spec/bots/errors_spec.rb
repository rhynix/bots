# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bots::Errors do
  describe "#formatted" do
    it "returns the type and errors" do
      errors = described_class.new("input", [
        Bots::Error.new("invalid input: bot 1 destroys all humans"),
        Bots::Error.new("bot(2) starts with more than two values")
      ])

      expect(errors.formatted).to eq(<<~EOF)
        input errors:
          invalid input: bot 1 destroys all humans
          bot(2) starts with more than two values
      EOF
    end
  end
end
