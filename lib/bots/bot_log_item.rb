module Bots
  class BotLogItem
    include Equatable[:from, :to, :value]

    attr_reader :from, :to, :value

    def initialize(from:, to:, value:)
      @from  = from
      @to    = to
      @value = value
    end

    def to_s
      "#{from} gives #{value} to #{to}"
    end
  end
end