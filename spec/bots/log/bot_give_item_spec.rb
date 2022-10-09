# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bots::Log::BotGiveItem do
  describe "#to_s" do
    let(:item) do
      described_class.new(
        from: Bots::Entities::Bot.new(42),
        to: Bots::Entities::Output.new(43),
        value: 6
      )
    end

    it "renders the type and id" do
      expect(item.to_s).to eq("bot(42) gives 6 to output(43)")
    end
  end
end
