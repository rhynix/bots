# frozen_string_literal: true

require "spec_helper"
require "timeout"

RSpec.describe Bots::Game do
  describe "#run" do
    context "input goes straight to output" do
      let(:result) do
        described_class.new(
          input_instructions: [
            Bots::Instructions::InputInstruction.new(
              to: Bots::Entities::Output.new(1),
              value: 50
            )
          ],
          bot_instructions: []
        ).run
      end

      it "returns the correct log items" do
        expect(result.log).to eq([
          Bots::Log::InputGiveItem.new(
            to: Bots::Entities::Output.new(1),
            value: 50
          )
        ])
      end

      it "returns the correct world" do
        expect(result.world).to eq({
          Bots::Entities::Output.new(1) => [50]
        })
      end
    end

    context "inputs go in one step to outputs" do
      let(:result) do
        described_class.new(
          input_instructions: [
            Bots::Instructions::InputInstruction.new(
              to: Bots::Entities::Bot.new(1),
              value: 25
            ),
            Bots::Instructions::InputInstruction.new(
              to: Bots::Entities::Bot.new(1),
              value: 75
            )
          ],
          bot_instructions: [
            Bots::Instructions::BotInstruction.new(
              from: Bots::Entities::Bot.new(1),
              low_to: Bots::Entities::Output.new(1),
              high_to: Bots::Entities::Output.new(2)
            )
          ]
        ).run
      end

      it "returns the correct log items" do
        expect(result.log).to eq([
          Bots::Log::InputGiveItem.new(
            to: Bots::Entities::Bot.new(1),
            value: 25
          ),
          Bots::Log::InputGiveItem.new(
            to: Bots::Entities::Bot.new(1),
            value: 75
          ),
          Bots::Log::BotCompareItem.new(
            bot: Bots::Entities::Bot.new(1),
            values: Set[25, 75]
          ),
          Bots::Log::BotGiveItem.new(
            from: Bots::Entities::Bot.new(1),
            to: Bots::Entities::Output.new(1),
            value: 25
          ),
          Bots::Log::BotGiveItem.new(
            from: Bots::Entities::Bot.new(1),
            to: Bots::Entities::Output.new(2),
            value: 75
          )
        ])
      end

      it "returns the correct world" do
        expect(result.world).to include({
          Bots::Entities::Output.new(1) => [25],
          Bots::Entities::Output.new(2) => [75]
        })
      end
    end

    context "inputs go in multiple step to outputs" do
      let(:result) do
        described_class.new(
          input_instructions: [
            Bots::Instructions::InputInstruction.new(
              to: Bots::Entities::Bot.new(2),
              value: 5
            ),
            Bots::Instructions::InputInstruction.new(
              to: Bots::Entities::Bot.new(1),
              value: 3
            ),
            Bots::Instructions::InputInstruction.new(
              to: Bots::Entities::Bot.new(2),
              value: 2
            )
          ],
          bot_instructions: [
            Bots::Instructions::BotInstruction.new(
              from: Bots::Entities::Bot.new(2),
              low_to: Bots::Entities::Bot.new(1),
              high_to: Bots::Entities::Bot.new(0)
            ),
            Bots::Instructions::BotInstruction.new(
              from: Bots::Entities::Bot.new(1),
              low_to: Bots::Entities::Output.new(1),
              high_to: Bots::Entities::Bot.new(0)
            ),
            Bots::Instructions::BotInstruction.new(
              from: Bots::Entities::Bot.new(0),
              low_to: Bots::Entities::Output.new(2),
              high_to: Bots::Entities::Output.new(0)
            )
          ]
        ).run
      end

      it "returns the correct log items" do
        expect(result.log).to eq([
          Bots::Log::InputGiveItem.new(
            to: Bots::Entities::Bot.new(2),
            value: 5
          ),
          Bots::Log::InputGiveItem.new(
            to: Bots::Entities::Bot.new(1),
            value: 3
          ),
          Bots::Log::InputGiveItem.new(
            to: Bots::Entities::Bot.new(2),
            value: 2
          ),
          Bots::Log::BotCompareItem.new(
            bot: Bots::Entities::Bot.new(2),
            values: Set[2, 5]
          ),
          Bots::Log::BotGiveItem.new(
            from: Bots::Entities::Bot.new(2),
            to: Bots::Entities::Bot.new(1),
            value: 2
          ),
          Bots::Log::BotGiveItem.new(
            from: Bots::Entities::Bot.new(2),
            to: Bots::Entities::Bot.new(0),
            value: 5
          ),
          Bots::Log::BotCompareItem.new(
            bot: Bots::Entities::Bot.new(1),
            values: Set[2, 3]
          ),
          Bots::Log::BotGiveItem.new(
            from: Bots::Entities::Bot.new(1),
            to: Bots::Entities::Output.new(1),
            value: 2
          ),
          Bots::Log::BotGiveItem.new(
            from: Bots::Entities::Bot.new(1),
            to: Bots::Entities::Bot.new(0),
            value: 3
          ),
          Bots::Log::BotCompareItem.new(
            bot: Bots::Entities::Bot.new(0),
            values: Set[3, 5]
          ),
          Bots::Log::BotGiveItem.new(
            from: Bots::Entities::Bot.new(0),
            to: Bots::Entities::Output.new(2),
            value: 3
          ),
          Bots::Log::BotGiveItem.new(
            from: Bots::Entities::Bot.new(0),
            to: Bots::Entities::Output.new(0),
            value: 5
          )
        ])
      end

      it "returns the correct world" do
        expect(result.world).to include({
          Bots::Entities::Output.new(0) => [5],
          Bots::Entities::Output.new(1) => [2],
          Bots::Entities::Output.new(2) => [3]
        })
      end
    end

    it "times out in case execution does not finish" do
      game = described_class.new(
        input_instructions: [
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(1),
            value: 25
          ),
          Bots::Instructions::InputInstruction.new(
            to: Bots::Entities::Bot.new(1),
            value: 75
          )
        ],
        bot_instructions: [
          Bots::Instructions::BotInstruction.new(
            from: Bots::Entities::Bot.new(1),
            low_to: Bots::Entities::Bot.new(1),
            high_to: Bots::Entities::Bot.new(1)
          )
        ]
      )

      expect { game.run(timeout: 0.001) }.to raise_error(Timeout::Error)
    end
  end
end
