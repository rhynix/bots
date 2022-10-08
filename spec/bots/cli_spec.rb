# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe Bots::CLI do
  def with_input_file(input)
    Tempfile.open do |file|
      file.write input
      file.rewind

      yield file.path
    end
  end

  describe "#call" do
    context "the input is invalid" do
      let(:result) do
        with_input_file("value 1 goes to bot 1") do |path|
          cli = described_class.new(path)
          cli.run
        end
      end

      it "returns failure" do
        expect(result.success?).to be(false)
      end

      it "returns the errors as out" do
        expect(result.out.formatted).to eq(<<~OUT)
          input errors:
            bot(1) has no operations
        OUT
      end
    end

    context "the game is successful" do
      let(:input) do
        <<~INPUT
          value 1 goes to bot 1
          value 2 goes to bot 1
          bot 1 gives low to output 2 and high to output 1
        INPUT
      end

      let(:result) do
        with_input_file(input) do |path|
          cli = described_class.new(path)
          cli.run
        end
      end

      it "returns success" do
        expect(result.success?).to be(true)
      end

      it "returns the log and outputs as out" do
        expect(result.out.formatted).to eq(<<~OUT)
          log:
            1 goes to bot(1)
            2 goes to bot(1)
            bot(1) is comparing 1 to 2
            bot(1) gives 1 to output(2)
            bot(1) gives 2 to output(1)
          world:
            output(2) = 1
            output(1) = 2
        OUT
      end
    end

    context "the output is invalid" do
      let(:input) do
        <<~INPUT
          value 1 goes to output 1
          value 2 goes to output 1
        INPUT
      end

      let(:result) do
        with_input_file(input) do |path|
          cli = described_class.new(path)
          cli.run
        end
      end

      it "returns failure" do
        expect(result.success?).to be(false)
      end

      it "returns the errors as out" do
        expect(result.out.formatted).to eq(<<~OUT)
          output errors:
            output(1) received multiple values: 1, 2
        OUT
      end
    end
  end
end
