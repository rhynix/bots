# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bots::PostValidator do
  describe "#call" do
    it "returns an empty array if there are no errors" do
      operations = [
        Bots::InputOperation.new(to: Bots::Bot.new(2), value: 6),
        Bots::InputOperation.new(to: Bots::Bot.new(2), value: 8)
      ]

      state = {
        Bots::Output.new(1) => [6],
        Bots::Output.new(2) => [8]
      }

      validator = described_class.new(operations, state)

      expect(validator.call).to eq([])
    end

    it "returns an error an output receives multiple values" do
      operations = [
        Bots::InputOperation.new(to: Bots::Bot.new(1), value: 9),
        Bots::InputOperation.new(to: Bots::Bot.new(2), value: 6)
      ]

      state = {
        Bots::Output.new(1) => [6, 9]
      }

      validator = described_class.new(operations, state)

      expect(validator.call).to contain_exactly(
        Bots::Error.new("output(1) received multiple values: 6, 9")
      )
    end
  end
end
