# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bots::PreValidator do
  describe "#call" do
    it "returns an empty array if there are no errors" do
      validator = described_class.new(
        input_instructions: [
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(2),
            value: 6
          ),
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(2),
            value: 8
          ),
        ],
        bot_instructions: [
          Bots::Instructions::BotInstruction.new(
            from: Bots::Entities::Bot.new(2),
            low_to: Bots::Entities::Output.new(1),
            high_to: Bots::Entities::Output.new(2)
          )
        ]
      )

      expect(validator.call).to eq([])
    end

    it "returns an error if multiple bots start with two values" do
      validator = described_class.new(
        input_instructions: [
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(2),
            value: 6
          ),
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(2),
            value: 8
          ),
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(6),
            value: 11
          ),
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(6),
            value: 5
          )
        ],
        bot_instructions: []
      )

      expect(validator.call).to include(
        Bots::Error.new("multiple bots start with two values: bot(2), bot(6)")
      )
    end

    it "returns an error if a bot starts with more than two values" do
      validator = described_class.new(
        input_instructions: [
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(2),
            value: 6
          ),
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(2),
            value: 8
          ),
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(2),
            value: 1
          ),
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(6),
            value: 8
          ),
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(6),
            value: 11
          )
        ],
        bot_instructions: []
      )

      expect(validator.call).to include(
        Bots::Error.new("bot(2) starts with more than two values")
      )
    end

    it "returns an error if a bot has more than one instruction" do
      validator = described_class.new(
        input_instructions: [],
        bot_instructions: [
        Bots::Instructions::BotInstruction.new(
          from: Bots::Entities::Bot.new(2),
          low_to: Bots::Entities::Output.new(1),
          high_to: Bots::Entities::Output.new(2)
        ),
        Bots::Instructions::BotInstruction.new(
          from: Bots::Entities::Bot.new(2),
          low_to: Bots::Entities::Output.new(2),
          high_to: Bots::Entities::Output.new(1)
        )
      ])

      expect(validator.call).to eq([
        Bots::Error.new("bot(2) has more than one instruction")
      ])
    end

    it "returns an error if a bot has no instructions" do
      validator = described_class.new(
        input_instructions: [
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(2),
            value: 6
          )
        ],
        bot_instructions:[
          Bots::Instructions::BotInstruction.new(
            from: Bots::Entities::Bot.new(3),
            low_to: Bots::Entities::Bot.new(2),
            high_to: Bots::Entities::Bot.new(4)
          )
        ]
      )

      expect(validator.call).to eq([
        Bots::Error.new("bot(2) has no instructions"),
        Bots::Error.new("bot(4) has no instructions")
      ])
    end
  end
end
