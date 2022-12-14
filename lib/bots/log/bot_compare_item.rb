# frozen_string_literal: true

module Bots
  module Log
    class BotCompareItem
      include Equatable[:bot, :values]

      attr_reader :bot, :values

      def initialize(bot:, values:)
        @bot    = bot
        @values = values
      end

      def to_s
        sorted_values = values.sort

        "#{bot} is comparing #{sorted_values.first} to #{sorted_values.last}"
      end
    end
  end
end
