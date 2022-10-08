# frozen_string_literal: true

module Bots
  class CLI
    Result = Struct.new(:success?, :out)

    attr_reader :input_path

    def initialize(input_path)
      @input_path = input_path
    end

    def run
      input  = File.read(input_path)
      inputs = input.lines.map(&:strip)

      input_result = OperationsParser.new(inputs).call
      input_errors = input_result.errors

      return failure("input", input_errors) if input_errors.any?

      operations = input_result.operations
      pre_errors = PreValidator.new(operations).call

      return failure("input", pre_errors) if pre_errors.any?

      state       = Game.new(operations).run
      post_errors = PostValidator.new(operations, state.world).call

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
