# frozen_string_literal: true

require "timeout"

module Bots
  class Game
    attr_reader :input_instructions, :bot_instructions

    def initialize(input_instructions:, bot_instructions:)
      @input_instructions = input_instructions
      @bot_instructions   = bot_instructions
    end

    def run(timeout: 5)
      Timeout.timeout(timeout) do
        _run
      end
    end

    private

    def _run
      state = GameState.new

      state = run_instructions(state, input_instructions)
      state = run_instructions(state, bot_instructions) until done?(state)

      state
    end

    def done?(state)
      bots = state.world.filter { |entity| entity.is_a?(Entities::Bot) }
      bots.values.all?(&:empty?)
    end

    def run_instructions(state, instructions)
      instructions.reduce(state) do |state, instruction|
        instruction.run_on(state)
      end
    end
  end
end
