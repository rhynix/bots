# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bots::Instructions::BotInstruction do
  describe "#run_on" do
    let(:bot) { Bots::Entities::Bot.new(42) }
    let(:receiver_low)  { Bots::Entities::Bot.new(44) }
    let(:receiver_high) { Bots::Entities::Bot.new(43) }

    let(:instruction) do
      described_class.new(
        from: bot,
        low_to: receiver_low,
        high_to: receiver_high
      )
    end

    context "the from bot has no values" do
      let(:original_state) do
        Bots::GameState.new(
          log: [
            Bots::Log::InputGiveItem.new(to: receiver_low, value: 10)
          ],
          world: {
            receiver_low => [10]
          }
        )
      end
      let(:state) { instruction.run_on(original_state) }

      it "returns the original state" do
        expect(state).to be(original_state)
      end
    end

    context "the from bot has one value" do
      let(:original_state) do
        Bots::GameState.new(
          log: [
            Bots::Log::InputGiveItem.new(to: receiver_low, value: 10),
            Bots::Log::InputGiveItem.new(to: bot, value: 6)
          ],
          world: {
            bot => [6],
            receiver_low => [10]
          }
        )
      end
      let(:state) { instruction.run_on(original_state) }

      it "returns the original state" do
        expect(state).to be(original_state)
      end
    end

    context "the from bot has two values" do
      let(:original_state) do
        Bots::GameState.new(
          log: [
            Bots::Log::InputGiveItem.new(to: receiver_low, value: 10),
            Bots::Log::InputGiveItem.new(to: bot, value: 6),
            Bots::Log::InputGiveItem.new(to: bot, value: 3)
          ],
          world: {
            bot => [6, 3],
            receiver_low => [10]
          }
        )
      end
      let(:state) { instruction.run_on(original_state) }

      it "returns the state with extra log items" do
        expect(state.log).to eq([
          Bots::Log::InputGiveItem.new(to: receiver_low, value: 10),
          Bots::Log::InputGiveItem.new(to: bot, value: 6),
          Bots::Log::InputGiveItem.new(to: bot, value: 3),
          Bots::Log::BotCompareItem.new(bot: bot, values: Set[3, 6]),
          Bots::Log::BotGiveItem.new(from: bot, to: receiver_low, value: 3),
          Bots::Log::BotGiveItem.new(from: bot, to: receiver_high, value: 6)
        ])
      end

      it "returns the state without any values for the giving bot" do
        expect(state.world).to include({
          bot => []
        })
      end

      it "returns the state with value for receiver without value" do
        expect(state.world).to include({
          receiver_high => [6]
        })
      end

      it "returns the state with extra value for receiver with value" do
        expect(state.world).to include({
          receiver_low => [10, 3]
        })
      end
    end
  end
end
