module Bots
  class InputOperation
    include Equatable[:value, :to]

    attr_reader :value, :to

    def initialize(value:, to:)
      @value = value
      @to    = to
    end

    def run_on(state)
      log_items     = [InputLogItem.new(to: to, value: value)]
      updated_state = { **state, to => [*state[to], value] }

      [log_items, updated_state]
    end
  end
end
