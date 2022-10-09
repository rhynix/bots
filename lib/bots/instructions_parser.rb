# frozen_string_literal: true

module Bots
  class InstructionsParser
    Result = Struct.new(:input_instructions, :bot_instructions, :errors)

    ENTITY_REGEXP = /\A(?<type>\w+) (?<id>\d+)\Z/i
    INPUT_REGEXP  = /\Avalue (?<value>\d+) goes to (?<entity>\w+ \d+)\Z/i
    BOT_REGEXP    = /\A(?<from>\w+ \d+) gives low to (?<low>\w+ \d+) and high to (?<high>\w+ \d+)\Z/i

    attr_reader :inputs

    def initialize(inputs)
      @inputs = inputs
    end

    def call
      result = Result.new([], [], [])

      inputs.each do |line|
        if instruction = try_parse_input_instruction(line)
          result.input_instructions << instruction
          next
        end

        if instruction = try_parse_bot_instruction(line)
          result.bot_instructions << instruction
          next
        end

        result.errors << Error.new("invalid input: #{line}")
      end

      result
    end

    private

    def try_parse_input_instruction(line)
      return nil unless match = INPUT_REGEXP.match(line)
      return nil unless to = entity(match[:entity])

      Instructions::InputInstruction.new(value: match[:value].to_i, to: to)
    end

    def try_parse_bot_instruction(line)
      return nil unless match = BOT_REGEXP.match(line)

      return nil unless from    = entity(match[:from])
      return nil unless low_to  = entity(match[:low])
      return nil unless high_to = entity(match[:high])

      Instructions::BotInstruction.new(
        from: from,
        low_to: low_to,
        high_to: high_to
      )
    end

    def entity(input)
      return nil unless match = ENTITY_REGEXP.match(input)
      return nil unless entity_class = entity_class(match[:type])

      entity_class.new(match[:id].to_i)
    end

    def entity_class(type)
      case type
      when 'bot'    then Entities::Bot
      when 'output' then Entities::Output
      else nil
      end
    end
  end
end
