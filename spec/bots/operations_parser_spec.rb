require "spec_helper"

RSpec.describe Bots::OperationsParser do
  describe "#operations" do
    it "returns deserialized goes to operations" do
      deserializer = described_class.new([
        "value 6 goes to bot 119",
        "value 7 goes to bot 102"
      ])

      expect(deserializer.call.operations).to contain_exactly(
        Bots::InputOperation.new(value: 6, to: Bots::Bot.new(119)),
        Bots::InputOperation.new(value: 7, to: Bots::Bot.new(102))
      )
    end

    it "returns deserialized gives to bot operations" do
      deserializer = described_class.new([
        "bot 13 gives low to bot 203 and high to bot 197",
        "bot 20 gives low to bot 146 and high to bot 164"
      ])

      expect(deserializer.call.operations).to contain_exactly(
        Bots::BotOperation.new(
          from: Bots::Bot.new(13),
          low_to: Bots::Bot.new(203),
          high_to: Bots::Bot.new(197)
        ),
        Bots::BotOperation.new(
          from: Bots::Bot.new(20),
          low_to: Bots::Bot.new(146),
          high_to: Bots::Bot.new(164)
        )
      )
    end

    it "returns deserialized gives to output operations" do
      deserializer = described_class.new([
        "bot 13 gives low to output 203 and high to output 197",
        "bot 20 gives low to output 146 and high to output 164"
      ])

      expect(deserializer.call.operations).to contain_exactly(
        Bots::BotOperation.new(
          from: Bots::Bot.new(13),
          low_to: Bots::Output.new(203),
          high_to: Bots::Output.new(197)
        ),
        Bots::BotOperation.new(
          from: Bots::Bot.new(20),
          low_to: Bots::Output.new(146),
          high_to: Bots::Output.new(164)
        )
      )
    end

    it "returns deserialized mixed operations" do
      deserializer = described_class.new([
        "value 6 goes to bot 119",
        "bot 13 gives low to bot 203 and high to output 197"
      ])

      expect(deserializer.call.operations).to contain_exactly(
        Bots::InputOperation.new(
          value: 6,
          to: Bots::Bot.new(119)
        ),
        Bots::BotOperation.new(
          from: Bots::Bot.new(13),
          low_to: Bots::Bot.new(203),
          high_to: Bots::Output.new(197)
        )
      )
    end

    it "returns an when an unknown operation is in the input" do
      deserializer = described_class.new([
        "value 6 goes to bot 119",
        "bot 13 takes low from bot 203 and high from bot 197"
      ])

      expect(deserializer.call.errors).to eq([
        Bots::OperationsParser::Error.new(
          "Invalid input: bot 13 takes low from bot 203 and high from bot 197"
        )
      ])
    end

    it "returns an error when an unknown type is in the input" do
      deserializer = described_class.new([
        "value 6 goes to bot 119",
        "bot 13 gives low to human 203 and high to bot 197"
      ])

      expect(deserializer.call.errors).to eq([
        Bots::OperationsParser::Error.new(
          "Invalid input: bot 13 gives low to human 203 and high to bot 197"
        )
      ])
    end
  end
end
