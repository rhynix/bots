# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bots::InstructionsParser do
  describe "#instructions" do
    it "returns deserialized input instructions" do
      deserializer = described_class.new([
        "value 6 goes to bot 119",
        "value 7 goes to bot 102"
      ])

      expect(deserializer.call.input_instructions).to contain_exactly(
        Bots::Instructions::InputInstruction.new(
          value: 6,
          to: Bots::Entities::Bot.new(119)
        ),
        Bots::Instructions::InputInstruction.new(
          value: 7,
          to: Bots::Entities::Bot.new(102)
        )
      )
    end

    it "returns deserialized bot to bot instructions" do
      deserializer = described_class.new([
        "bot 13 gives low to bot 203 and high to bot 197",
        "bot 20 gives low to bot 146 and high to bot 164"
      ])

      expect(deserializer.call.bot_instructions).to contain_exactly(
        Bots::Instructions::BotInstruction.new(
          from: Bots::Entities::Bot.new(13),
          low_to: Bots::Entities::Bot.new(203),
          high_to: Bots::Entities::Bot.new(197)
        ),
        Bots::Instructions::BotInstruction.new(
          from: Bots::Entities::Bot.new(20),
          low_to: Bots::Entities::Bot.new(146),
          high_to: Bots::Entities::Bot.new(164)
        )
      )
    end

    it "returns deserialized bot to output instructions" do
      deserializer = described_class.new([
        "bot 13 gives low to output 203 and high to output 197",
        "bot 20 gives low to output 146 and high to output 164"
      ])

      expect(deserializer.call.bot_instructions).to contain_exactly(
        Bots::Instructions::BotInstruction.new(
          from: Bots::Entities::Bot.new(13),
          low_to: Bots::Entities::Output.new(203),
          high_to: Bots::Entities::Output.new(197)
        ),
        Bots::Instructions::BotInstruction.new(
          from: Bots::Entities::Bot.new(20),
          low_to: Bots::Entities::Output.new(146),
          high_to: Bots::Entities::Output.new(164)
        )
      )
    end

    it "returns deserialized mixed instructions" do
      deserializer = described_class.new([
        "value 6 goes to bot 119",
        "bot 13 gives low to bot 203 and high to output 197"
      ])

      expect(deserializer.call).to have_attributes(
        input_instructions: [
          Bots::Instructions::InputInstruction.new(
            value: 6,
            to: Bots::Entities::Bot.new(119)
          )
        ],
        bot_instructions: [
          Bots::Instructions::BotInstruction.new(
            from: Bots::Entities::Bot.new(13),
            low_to: Bots::Entities::Bot.new(203),
            high_to: Bots::Entities::Output.new(197)
          )
        ]
      )
    end

    it "returns an when an unknown instruction is in the input" do
      deserializer = described_class.new([
        "value 6 goes to bot 119",
        "bot 13 takes low from bot 203 and high from bot 197"
      ])

      expect(deserializer.call.errors).to eq([
        Bots::Error.new(
          "invalid input: bot 13 takes low from bot 203 and high from bot 197"
        )
      ])
    end

    it "returns an error when an unknown type is in the input" do
      deserializer = described_class.new([
        "value 6 goes to bot 119",
        "bot 13 gives low to human 203 and high to bot 197"
      ])

      expect(deserializer.call.errors).to eq([
        Bots::Error.new(
          "invalid input: bot 13 gives low to human 203 and high to bot 197"
        )
      ])
    end
  end
end
