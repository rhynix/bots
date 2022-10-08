require "spec_helper"

RSpec.describe Bots::PostValidator do
  describe "#call" do
    it "returns an empty array if there are no errors" do
      operations = [
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 6),
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 8),
      ]

      state = {
        Bots::Output.new(1) => [6],
        Bots::Output.new(2) => [8]
      }

      validator = described_class.new(operations, state)

      expect(validator.call).to eq([])
    end

    it "returns an error if not all values end up at outputs" do
      operations = [
        Bots::GoesToOperation.new(to: Bots::Bot.new(1), value: 9),
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 6),
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 8),
      ]

      state = {
        Bots::Output.new(1) => [6],
        Bots::Bot.new(2) => [8],
      }

      validator = described_class.new(operations, state)

      expect(validator.call).to contain_exactly(
        Bots::AssertionError.new("Input value missing from output: 8"),
        Bots::AssertionError.new("Input value missing from output: 9")
      )
    end

    it "returns an error if extra values end up at outputs" do
      operations = [
        Bots::GoesToOperation.new(to: Bots::Bot.new(1), value: 9),
      ]

      state = {
        Bots::Output.new(1) => [6],
        Bots::Output.new(2) => [9]
      }

      validator = described_class.new(operations, state)

      expect(validator.call).to contain_exactly(
        Bots::AssertionError.new("Unexpected output value: 6")
      )
    end

    it "returns an error an output receives multiple values" do
      operations = [
        Bots::GoesToOperation.new(to: Bots::Bot.new(1), value: 9),
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 6),
      ]

      state = {
        Bots::Output.new(1) => [6, 9]
      }

      validator = described_class.new(operations, state)

      expect(validator.call).to contain_exactly(
        Bots::AssertionError.new("Output 1 received multiple values: 6, 9")
      )
    end
  end
end
