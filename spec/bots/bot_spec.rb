# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bots::Bot do
  describe "#to_s" do
    let(:bot) { described_class.new(42) }

    it "renders the type and id" do
      expect(bot.to_s).to eq("bot(42)")
    end
  end
end
