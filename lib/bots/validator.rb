module Bots
  class Validator
    AssertionError = Class.new(RuntimeError)

    attr_reader :operations

    def initialize(operations)
      @operations = operations
    end

    def call
      [
        *validate_max_two_values_per_bot,
        *validate_one_bot_with_two_values
      ]
    end

    private

    def validate_one_bot_with_two_values
      bots       = goes_to_operations_per_bot.keys
      start_bots = bots.filter { |b| goes_to_operations_per_bot[b].length == 2 }

      if start_bots.length > 1
        bot_ids = start_bots.map(&:id).join(", ")
        message = "Multiple bots start with two values: #{bot_ids}"

        [AssertionError.new(message)]
      end
    end

    def validate_max_two_values_per_bot
      goes_to_operations_per_bot.flat_map do |bot, ops|
        if ops.length > 2
          [AssertionError.new("Bot #{bot.id} starts with more than two values")]
        else
          []
        end
      end
    end

    def goes_to_operations_per_bot
      @operations_per_bot ||= operations
        .filter { |operation| operation.is_a?(Bots::GoesToOperation) }
        .filter { |operation| operation.to.is_a?(Bots::Bot) }
        .group_by(&:to)
    end
  end
end
