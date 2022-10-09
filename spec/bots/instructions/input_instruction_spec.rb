# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bots::Instructions::InputInstruction do
  describe "#run_on" do
    let(:bot) { Bots::Entities::Bot.new(42) }
    let(:instruction) { described_class.new(value: 6, to: bot) }

    context "the entity already has no value" do
      let(:original_state) { Bots::GameState.new }
      let(:state) { instruction.run_on(original_state) }

      it "returns a state with an added log item" do
        expect(state.log).to eq([
          Bots::Log::InputGiveItem.new(value: 6, to: bot)
        ])
      end

      it "returns a state with a value for the entity" do
        expect(state.world).to eq({ bot => [6] })
      end
    end

    context "the entity already has a value" do
      let(:original_state) do
        Bots::GameState.new(
          log: [Bots::Log::InputGiveItem.new(value: 3, to: bot)],
          world: { bot => [3] }
        )
      end

      let(:state) { instruction.run_on(original_state) }

      it "returns a state with an added log item" do
        expect(state.log).to eq([
          Bots::Log::InputGiveItem.new(value: 3, to: bot),
          Bots::Log::InputGiveItem.new(value: 6, to: bot)
        ])
      end

      it "returns a state with an extra value for the entity" do
        expect(state.world).to eq({ bot => [3, 6] })
      end
    end
  end
end
