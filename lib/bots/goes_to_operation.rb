module Bots
  class GoesToOperation
    include Equatable[:value, :to]

    attr_reader :value, :to

    def initialize(value:, to:)
      @value = value
      @to    = to
    end

    def run_on(state)
      new_values = [*state[to], value]

      {
        **state,
        to => new_values
      }
    end
  end
end
