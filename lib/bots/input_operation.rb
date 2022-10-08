# frozen_string_literal: true

module Bots
  class InputOperation
    include Equatable[:value, :to]

    attr_reader :value, :to

    def initialize(value:, to:)
      @value = value
      @to    = to
    end

    def run_on(state)
      state
        .add_to_log(InputLogItem.new(to: to, value: value))
        .update_world({ to => [*state.world[to], value] })
    end
  end
end
