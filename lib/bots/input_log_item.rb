module Bots
  class InputLogItem
    attr_reader :to, :value

    def initialize(to:, value:)
      @to    = to
      @value = value
    end

    def to_s
      "#{value} goes to #{to}"
    end
  end
end
