# frozen_string_literal: true

require "timeout"

module Bots
  class Game
    attr_reader :instructions

    def initialize(instructions)
      @instructions = instructions
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

    def input_instructions
      instructions_of_type(Instructions::InputInstruction)
    end

    def bot_instructions
      instructions_of_type(Instructions::BotInstruction)
    end

    def instructions_of_type(type)
      instructions.filter { |instruction| instruction.is_a?(type) }
    end
  end
end
