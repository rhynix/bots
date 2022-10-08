require "spec_helper"
require "timeout"

RSpec.describe Bots::Game do
  describe "#run" do
    it "returns straight goes to output items" do
      game = described_class.new([
        Bots::GoesToOperation.new(to: Bots::Output.new(100), value: 50)
      ])

      expect(game.run[:current]).to eq({
        Bots::Output.new(100) => [50]
      })
    end

    it "returns items after simple processing by bots" do
      game = described_class.new([
        Bots::GoesToOperation.new(to: Bots::Bot.new(1), value: 25),
        Bots::GoesToOperation.new(to: Bots::Bot.new(1), value: 75),
        Bots::GivesToOperation.new(
          from: Bots::Bot.new(1),
          low_to: Bots::Output.new(1),
          high_to: Bots::Output.new(2)
        )
      ])

      expect(game.run[:current]).to include({
        Bots::Output.new(1) => [25],
        Bots::Output.new(2) => [75]
      })
    end

    it "returns items after more complex processing by bots" do
      game = described_class.new([
        Bots::GoesToOperation.new(to: Bots::Bot.new(1), value: 10),
        Bots::GoesToOperation.new(to: Bots::Bot.new(1), value: 20),
        Bots::GoesToOperation.new(to: Bots::Bot.new(2), value: 30),
        Bots::GivesToOperation.new(
          from: Bots::Bot.new(1),
          low_to: Bots::Output.new(1),
          high_to: Bots::Bot.new(2)
        ),
        Bots::GivesToOperation.new(
          from: Bots::Bot.new(2),
          low_to: Bots::Output.new(3),
          high_to: Bots::Output.new(2)
        )
      ])

      expect(game.run[:current]).to include({
        Bots::Output.new(1) => [10],
        Bots::Output.new(2) => [30],
        Bots::Output.new(3) => [20],
      })
    end

    it "times out in case execution does not finish" do
      game = described_class.new([
        Bots::GoesToOperation.new(to: Bots::Bot.new(1), value: 25),
        Bots::GoesToOperation.new(to: Bots::Bot.new(1), value: 75),
        Bots::GivesToOperation.new(
          from: Bots::Bot.new(1),
          low_to: Bots::Bot.new(1),
          high_to: Bots::Bot.new(1)
        )
      ])

      expect { game.run(timeout: 0.001) }.to raise_error(Timeout::Error)
    end
  end
end
