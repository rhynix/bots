# frozen_string_literal: true

module Bots
  class PreValidator
    attr_reader :input_instructions, :bot_instructions

    def initialize(input_instructions:, bot_instructions:)
      @input_instructions = input_instructions
      @bot_instructions   = bot_instructions
    end

    def call
      [
        *validate_max_two_values_per_bot,
        *validate_one_bot_with_two_values,
        *validate_one_instruction_per_bot
      ]
    end

    private

    def validate_one_instruction_per_bot
      bot_instructions_per_bot = bot_instructions.group_by(&:from)

      all_bots.flat_map do |bot|
        case bot_instructions_per_bot.fetch(bot, []).length
        when 0
          [Error.new("#{bot} has no instructions")]
        when (2..)
          [Error.new("#{bot} has more than one instruction")]
        else
          []
        end
      end
    end

    def validate_one_bot_with_two_values
      bots = input_instructions_per_bot
        .filter { |bot, values| values.length == 2 }
        .keys

      if bots.length > 1
        bots    = bots.join(", ")
        message = "multiple bots start with two values: #{bots}"

        [Error.new(message)]
      else
        []
      end
    end

    def validate_max_two_values_per_bot
      input_instructions_per_bot.flat_map do |bot, instructions|
        if instructions.length > 2
          [Error.new("#{bot} starts with more than two values")]
        else
          []
        end
      end
    end

    def all_bots
      entities = [
        *input_instructions.map(&:to),
        *bot_instructions.map(&:from),
        *bot_instructions.map(&:low_to),
        *bot_instructions.map(&:high_to)
      ]

      entities.filter { |entity| entity.is_a?(Entities::Bot) }.uniq
    end

    def input_instructions_per_bot
      input_instructions
        .filter { |instruction| instruction.to.is_a?(Entities::Bot) }
        .group_by(&:to)
    end
  end
end
