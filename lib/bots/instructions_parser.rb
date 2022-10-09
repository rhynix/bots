# frozen_string_literal: true

module Bots
  class InstructionsParser
    Result = Struct.new(:instructions, :errors)

    ENTITY_REGEXP = /\A(?<type>\w+) (?<id>\d+)\Z/i
    INPUT_REGEXP  = /\Avalue (?<value>\d+) goes to (?<entity>\w+ \d+)\Z/i
    BOT_REGEXP    = /\A(?<from>\w+ \d+) gives low to (?<low>\w+ \d+) and high to (?<high>\w+ \d+)\Z/i

    attr_reader :inputs

    def initialize(inputs)
      @inputs = inputs
    end

    def call
      result = Result.new([], [])

      inputs.each do |input|
        if instruction = parse(input)
          result.instructions << instruction
        else
          result.errors << Error.new("invalid input: #{input}")
        end
      end

      result
    end

    private

    def parse(line)
      case line
      when INPUT_REGEXP
        match = $~
        to    = entity(match[:entity]) or return nil

        Instructions::InputInstruction.new(value: $~[:value].to_i, to: to)
      when BOT_REGEXP
        match = $~

        from    = entity(match[:from]) or return nil
        low_to  = entity(match[:low])  or return nil
        high_to = entity(match[:high]) or return nil

        Instructions::BotInstruction.new(
          from: from,
          low_to: low_to,
          high_to: high_to
        )
      else
        nil
      end
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