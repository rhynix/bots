# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bots::GameState do
  describe "#add_to_log" do
    it "return a state with the added log item" do
      item_1 = Bots::InputLogItem.new(to: Bots::Output.new(42), value: 6)
      item_2 = Bots::InputLogItem.new(to: Bots::Bot.new(42), value: 12)

      original = described_class.new(log: [item_1])
      state    = original.add_to_log(item_2)

      expect(state.log).to eq([item_1, item_2])
    end
  end

  describe "#update_world" do
    it "return correct state when an entity is updated" do
      bot    = Bots::Bot.new(42)
      output = Bots::Output.new(43)
      world  = { bot => [5], output => [10] }

      original = described_class.new(world: world)
      state    = original.update_world({ bot => [5, 6] })

      expect(state.world).to eq({ bot => [5, 6], output => [10] })
    end

    it "return correct state when an entity is added" do
      bot    = Bots::Bot.new(42)
      output = Bots::Output.new(43)
      world  = { output => [10] }

      original = described_class.new(world: world)
      state    = original.update_world({ bot => [5] })

      expect(state.world).to eq({ bot => [5], output => [10] })
    end
  end

  describe "#formatted" do
    it "includes log items" do
      state = described_class.new(
        log: [
          Bots::InputLogItem.new(to: Bots::Output.new(42), value: 6),
          Bots::InputLogItem.new(to: Bots::Bot.new(42), value: 12)
        ]
      )

      expect(state.formatted).to include(<<~EOF)
        log:
          6 goes to output(42)
          12 goes to bot(42)
      EOF
    end

    it "includes the world" do
      state = described_class.new(
        world: {
          Bots::Output.new(42) => [6],
          Bots::Bot.new(43) => [3]
        }
      )

      expect(state.formatted).to include(<<~EOF)
        world:
          output(42) = 6
          bot(43) = 3
      EOF
    end
  end
end
