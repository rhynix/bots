module Bots
  class GoesToOperation
    include Equatable[:value, :to]

    attr_reader :value, :to

    def initialize(value:, to:)
      @value = value
      @to    = to
    end

    def run_on(state)
      executions    = [InputExecution.new(to: to, value: value)]
      updated_state = { **state, to => [*state[to], value] }

      [executions, updated_state]
    end
  end
end
