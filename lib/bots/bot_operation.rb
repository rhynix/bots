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
      return state unless state.world.fetch(from, []).length == 2

      world = state.world

      low_value  = world[from].min
      high_value = world[from].max

      state
        .add_to_log(BotLogItem.new(from: from, to: low_to, value: low_value))
        .add_to_log(BotLogItem.new(from: from, to: high_to, value: high_value))
        .update_world({
          from    => [],
          low_to  => [*world[low_to],  low_value],
          high_to => [*world[high_to], high_value]
        })
    end
  end
end
