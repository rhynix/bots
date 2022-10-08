require "spec_helper"

RSpec.describe Bots::Output do
  describe "#to_s" do
    let(:output) { described_class.new(42) }

    it "renders the type and id" do
      expect(output.to_s).to eq("output(42)")
    end
  end
end
