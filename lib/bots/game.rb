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
      state = { log: [], current: {} }

      state = run_ops(state, ops(GoesToOperation))
      state = run_ops(state, ops(GivesToOperation)) until done?(state)

      state
    end

    def done?(state)
      current = state[:current]
      bots_current = current.filter { |entity| entity.is_a?(Bot) }
      bots_current.values.all?(&:empty?)
    end

    def run_ops(state, ops)
      ops.reduce(state) do |acc, operation|
        executions, current = operation.run_on(acc[:current])
        log = [*acc[:log], *executions]

        { log: log, current: current }
      end
    end

    def ops(type)
      operations.filter { |operation| operation.is_a?(type) }
    end
  end
end
