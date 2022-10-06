module Bots
  class GivesToOperation
    include Equatable[:from, :low_to, :high_to]

    attr_reader :from, :low_to, :high_to

    def initialize(from:, low_to:, high_to:)
      @from    = from
      @low_to  = low_to
      @high_to = high_to
    end

    def run_on(state)
      if state[from] && state[from].length == 2
        {
          **state,
          from    => [],
          low_to  => [*state[low_to],  state[from].min],
          high_to => [*state[high_to], state[from].max]
        }
      else
        state
      end
    end
  end
end
