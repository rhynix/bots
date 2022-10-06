require "spec_helper"

RSpec.describe Bots::Validator do
  describe "#call" do
    AssertionError = Bots::Validator::AssertionError

    it "returns an empty array if there are no errors" do
      validator = described_class.new([
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 6),
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 8)
      ])

      expect(validator.call).to eq([])
    end

    it "returns an error if multiple bots start with two values" do
      validator = described_class.new([
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 6),
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 8),
        Bots::GoesToOperation.new(to: Bots::Bot.new(6), value: 11),
        Bots::GoesToOperation.new(to: Bots::Bot.new(6), value: 5)
      ])

      expect(validator.call).to eq([
        AssertionError.new("Multiple bots start with two values: 2, 6")
      ])
    end

    it "returns an error if a bot starts with more than two values" do
      validator = described_class.new([
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 6),
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 8),
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 1),
        Bots::GoesToOperation.new(to: Bots::Bot.new(6), value: 8),
        Bots::GoesToOperation.new(to: Bots::Bot.new(6), value: 11)
      ])

      expect(validator.call).to eq([
        AssertionError.new("Bot 2 starts with more than two values")
      ])
    end

    it "returns no errors for gives to operations" do
      validator = described_class.new([
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 6),
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 8),
        Bots::GivesToOperation.new(
          from: Bots::Bot.new(2),
          low_to: Bots::Bot.new(6),
          high_to: Bots::Bot.new(9)
        )
      ])

      expect(validator.call).to eq([])
    end
  end
end
