# frozen_string_literal: true

module Bots
  class PreValidator
    attr_reader :operations

    def initialize(operations)
      @operations = operations
    end

    def call
      [
        *validate_max_two_values_per_bot,
        *validate_one_bot_with_two_values,
        *validate_one_operation_per_bot
      ]
    end

    private

    def validate_one_operation_per_bot
      bot_operations = operations_of_type(BotOperation).group_by(&:from)

      all_bots.flat_map do |bot|
        case bot_operations.fetch(bot, []).length
        when 0
          [AssertionError.new("Bot #{bot.id} has no operations")]
        when (2..)
          [AssertionError.new("Bot #{bot.id} has more than one operation")]
        else
          []
        end
      end
    end

    def validate_one_bot_with_two_values
      bots       = goes_to_operations_per_bot.keys
      start_bots = bots.filter { |b| goes_to_operations_per_bot[b].length == 2 }

      if start_bots.length > 1
        bot_ids = start_bots.map(&:id).join(", ")
        message = "Multiple bots start with two values: #{bot_ids}"

        [AssertionError.new(message)]
      else
        []
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

    def all_bots
      goes_to_bots = operations_of_type(InputOperation)
        .map(&:to)
        .filter { |entity| entity.is_a?(Bot) }

      gives_to_bots = operations_of_type(BotOperation).map(&:from)

      [*goes_to_bots, *gives_to_bots].uniq
    end

    def goes_to_operations_per_bot
      operations_of_type(InputOperation)
        .filter { |operation| operation.to.is_a?(Bot) }
        .group_by(&:to)
    end

    def operations_of_type(type)
      operations.filter { |operation| operation.is_a?(type) }
    end
  end
end
