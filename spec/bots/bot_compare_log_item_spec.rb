require "spec_helper"

RSpec.describe Bots::BotCompareLogItem do
  describe "#to_s" do
    let(:item) do
      described_class.new(
        bot: Bots::Bot.new(42),
        values: Set[4, 2]
      )
    end

    it "renders the type and id" do
      expect(item.to_s).to eq("bot(42) is comparing 2 to 4")
    end
  end
end
