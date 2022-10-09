# frozen_string_literal: true

module Bots
  class Runner
    Result = Struct.new(:success?, :out)

    attr_reader :lines

    def initialize(lines)
      @lines = lines
    end

    def run
      parse_result = InstructionsParser.new(lines).call
      parse_errors = parse_result.errors

      return failure("parse", parse) if parse_errors.any?

      pre_errors = PreValidator.new(
        input_instructions: parse_result.input_instructions,
        bot_instructions: parse_result.bot_instructions
      ).call
      return failure("input", pre_errors) if pre_errors.any?

      state = Game.new(
        input_instructions: parse_result.input_instructions,
        bot_instructions: parse_result.bot_instructions
      ).run

      post_errors = PostValidator.new(state.world).call
      return failure("output", post_errors) if post_errors.any?

      return success(state)
    end

    private

    def success(state)
      Result.new(true, state)
    end

    def failure(type, errors)
      Result.new(false, Errors.new(type, errors))
    end
  end
end
