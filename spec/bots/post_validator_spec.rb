# frozen_string_literal: true

require "spec_helper"

RSpec.describe Bots::PostValidator do
  describe "#call" do
    it "returns an empty array if there are no errors" do
      validator = described_class.new({
        Bots::Output.new(1) => [6],
        Bots::Output.new(2) => [8]
      })

      expect(validator.call).to eq([])
    end

    it "returns an error an output receives multiple values" do
      validator = described_class.new({
        Bots::Output.new(1) => [6, 9]
      })

      expect(validator.call).to contain_exactly(
        Bots::Error.new("output(1) received multiple values: 6, 9")
      )
    end
  end
end
