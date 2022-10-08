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
    context "not enough arguments were provided" do
      it "prints the usage" do
        out = StringIO.new
        cli = described_class.new("bots", [], out)
        cli.run

        expect(out.string.strip).to eq("usage: bots input-file")
      end

      it "returns false" do
        out = StringIO.new
        cli = described_class.new("bots", [], out)

        expect(cli.run).to be(false)
      end
    end

    context "the input is invalid" do
      it "returns false" do
        out   = StringIO.new
        input = "value 1 goes to bot 1"

        with_input_file(input) do |path|
          cli = described_class.new("bots", [path], out)
          expect(cli.run).to be(false)
        end
      end

      it "prints the errors" do
        out   = StringIO.new
        input = "value 1 goes to bot 1"

        with_input_file(input) do |path|
          cli = described_class.new("bots", [path], out)
          cli.run
        end

        expect(out.string).to eq(<<~OUT)
          One or more input errors:
          * Bot 1 has no operations
        OUT
      end
    end

    context "the game is successful" do
      it "returns true" do
        out = StringIO.new
        input = <<~INPUT
          value 1 goes to bot 1
          value 2 goes to bot 1
          bot 1 gives low to output 2 and high to output 1
        INPUT

        with_input_file(input) do |path|
          cli = described_class.new("bots", [path], out)
          expect(cli.run).to be(true)
        end
      end

      it "prints the outputs" do
        out = StringIO.new
        input = <<~INPUT
          value 1 goes to bot 1
          value 2 goes to bot 1
          bot 1 gives low to output 2 and high to output 1
        INPUT

        with_input_file(input) do |path|
          cli = described_class.new("bots", [path], out)
          cli.run
        end

        expect(out.string).to eq(<<~OUT)
          output( 1 ) = 2
          output( 2 ) = 1
        OUT
      end
    end

    context "the output is invalid" do
      it "returns true" do
        out = StringIO.new
        input = <<~INPUT
          value 1 goes to output 1
          value 2 goes to output 1
        INPUT

        with_input_file(input) do |path|
          cli = described_class.new("bots", [path], out)
          expect(cli.run).to be(false)
        end
      end

      it "prints the outputs" do
        out = StringIO.new
        input = <<~INPUT
          value 1 goes to output 1
          value 2 goes to output 1
        INPUT

        with_input_file(input) do |path|
          cli = described_class.new("bots", [path], out)
          cli.run
        end

        expect(out.string).to eq(<<~OUT)
          One or more output errors:
          * Output 1 received multiple values: 1, 2
        OUT
      end
    end
  end
end
