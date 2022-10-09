# frozen_string_literal: true

module Bots
  module Log
    class InputGiveItem
      include Equatable[:to, :value]

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
end
