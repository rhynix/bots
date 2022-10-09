# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bots::Log::InputGiveItem do
  describe "#to_s" do
    let(:item) do
      described_class.new(
        to: Bots::Entities::Bot.new(42),
        value: 4
      )
    end

    it "renders the type and id" do
      expect(item.to_s).to eq("4 goes to bot(42)")
    end
  end
end
