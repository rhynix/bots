require "spec_helper"
require "timeout"

RSpec.describe Bots::Game do
  describe "#run" do
    context "input goes straight to output" do
      let(:result) do
        described_class.new([
          Bots::InputOperation.new(to: Bots::Output.new(100), value: 50)
        ]).run
      end

      it "returns the correct log items" do
        expect(result.log).to eq([
          Bots::InputLogItem.new(to: Bots::Output.new(100), value: 50)
        ])
      end

      it "returns the correct world" do
        expect(result.world).to eq({
          Bots::Output.new(100) => [50]
        })
      end
    end

    context "inputs go in one step to outputs" do
      let(:result) do
        described_class.new([
          Bots::InputOperation.new(to: Bots::Bot.new(1), value: 25),
          Bots::InputOperation.new(to: Bots::Bot.new(1), value: 75),
          Bots::BotOperation.new(
            from: Bots::Bot.new(1),
            low_to: Bots::Output.new(1),
            high_to: Bots::Output.new(2)
          )
        ]).run
      end

      it "returns the correct log items" do
        expect(result.log).to eq([
          Bots::InputLogItem.new(to: Bots::Bot.new(1), value: 25),
          Bots::InputLogItem.new(to: Bots::Bot.new(1), value: 75),
          Bots::BotCompareLogItem.new(
            bot: Bots::Bot.new(1),
            values: Set[25, 75],
          ),
          Bots::BotGiveLogItem.new(
            from: Bots::Bot.new(1),
            to: Bots::Output.new(1),
            value: 25
          ),
          Bots::BotGiveLogItem.new(
            from: Bots::Bot.new(1),
            to: Bots::Output.new(2),
            value: 75
          )
        ])
      end

      it "returns the correct world" do
        expect(result.world).to include({
          Bots::Output.new(1) => [25],
          Bots::Output.new(2) => [75]
        })
      end
    end

    context "inputs go in multiple step to outputs" do
      let(:result) do
        described_class.new([
          Bots::InputOperation.new(to: Bots::Bot.new(2), value: 5),
          Bots::BotOperation.new(
            from: Bots::Bot.new(2),
            low_to: Bots::Bot.new(1),
            high_to: Bots::Bot.new(0)
          ),
          Bots::InputOperation.new(to: Bots::Bot.new(1), value: 3),
          Bots::InputOperation.new(to: Bots::Bot.new(2), value: 2),
          Bots::BotOperation.new(
            from: Bots::Bot.new(1),
            low_to: Bots::Output.new(1),
            high_to: Bots::Bot.new(0)
          ),
          Bots::BotOperation.new(
            from: Bots::Bot.new(0),
            low_to: Bots::Output.new(2),
            high_to: Bots::Output.new(0)
          )
        ]).run
      end

      it "returns the correct log items" do
        expect(result.log).to eq([
          Bots::InputLogItem.new(to: Bots::Bot.new(2), value: 5),
          Bots::InputLogItem.new(to: Bots::Bot.new(1), value: 3),
          Bots::InputLogItem.new(to: Bots::Bot.new(2), value: 2),
          Bots::BotCompareLogItem.new(
            bot: Bots::Bot.new(2),
            values: Set[2, 5]
          ),
          Bots::BotGiveLogItem.new(
            from: Bots::Bot.new(2),
            to: Bots::Bot.new(1),
            value: 2
          ),
          Bots::BotGiveLogItem.new(
            from: Bots::Bot.new(2),
            to: Bots::Bot.new(0),
            value: 5
          ),
          Bots::BotCompareLogItem.new(
            bot: Bots::Bot.new(1),
            values: Set[2, 3]
          ),
          Bots::BotGiveLogItem.new(
            from: Bots::Bot.new(1),
            to: Bots::Output.new(1),
            value: 2
          ),
          Bots::BotGiveLogItem.new(
            from: Bots::Bot.new(1),
            to: Bots::Bot.new(0),
            value: 3
          ),
          Bots::BotCompareLogItem.new(
            bot: Bots::Bot.new(0),
            values: Set[3, 5]
          ),
          Bots::BotGiveLogItem.new(
            from: Bots::Bot.new(0),
            to: Bots::Output.new(2),
            value: 3
          ),
          Bots::BotGiveLogItem.new(
            from: Bots::Bot.new(0),
            to: Bots::Output.new(0),
            value: 5
          )
        ])
      end

      it "returns the correct world" do
        expect(result.world).to include({
          Bots::Output.new(0) => [5],
          Bots::Output.new(1) => [2],
          Bots::Output.new(2) => [3],
        })
      end
    end

    it "times out in case execution does not finish" do
      game = described_class.new([
        Bots::InputOperation.new(to: Bots::Bot.new(1), value: 25),
        Bots::InputOperation.new(to: Bots::Bot.new(1), value: 75),
        Bots::BotOperation.new(
          from: Bots::Bot.new(1),
          low_to: Bots::Bot.new(1),
          high_to: Bots::Bot.new(1)
        )
      ])

      expect { game.run(timeout: 0.001) }.to raise_error(Timeout::Error)
    end
  end
end
