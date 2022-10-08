require "timeout"

module Bots
  class Game
    attr_reader :operations

    def initialize(operations)
      @operations = operations
    end

    def run(timeout: 5)
      state = {}

      Timeout.timeout(timeout) do
        state = run_ops(state, ops_of_type(GoesToOperation))
        state = run_ops(state, ops_of_type(GivesToOperation)) until done?(state)
      end

      state
    end

    private

    def done?(state)
      bot_keys   = state.keys.filter { |entity| entity.is_a?(Bot) }
      bot_values = state.values_at(*bot_keys)

      bot_values.all?(&:empty?)
    end

    def run_ops(state, ops)
      ops.reduce(state) { |acc, operation| operation.run_on(acc) }
    end

    def ops_of_type(type)
      operations.filter { |operation| operation.is_a?(type) }
    end
  end
end
