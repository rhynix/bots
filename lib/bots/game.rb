# frozen_string_literal: true

require "timeout"

module Bots
  class Game
    attr_reader :operations

    def initialize(operations)
      @operations = operations
    end

    def run(timeout: 5)
      Timeout.timeout(timeout) do
        _run
      end
    end

    private

    def _run
      state = GameState.new

      state = run_ops(state, ops(InputOperation))
      state = run_ops(state, ops(BotOperation)) until done?(state)

      state
    end

    def done?(state)
      bots = state.world.filter { |entity| entity.is_a?(Bot) }
      bots.values.all?(&:empty?)
    end

    def run_ops(state, ops)
      ops.reduce(state) { |state, operation| operation.run_on(state) }
    end

    def ops(type)
      operations.filter { |operation| operation.is_a?(type) }
    end
  end
end
