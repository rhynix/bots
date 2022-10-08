module Bots
  class BotOperation
    include Equatable[:from, :low_to, :high_to]

    attr_reader :from, :low_to, :high_to

    def initialize(from:, low_to:, high_to:)
      @from    = from
      @low_to  = low_to
      @high_to = high_to
    end

    def run_on(state)
      return [[], state] unless state[from] && state[from].length == 2

      low_value  = state[from].min
      high_value = state[from].max

      executions = [
        BotExecution.new(from: from, to: low_to, value: low_value),
        BotExecution.new(from: from, to: high_to, value: high_value)
      ]

      updated_state = {
        **state,
        from    => [],
        low_to  => [*state[low_to],  state[from].min],
        high_to => [*state[high_to], state[from].max]
      }

      [executions, updated_state]
    end
  end
end
