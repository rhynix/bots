module Bots
  class OperationsDeserializer
    Error  = Class.new(RuntimeError)
    Result = Struct.new(:operations, :errors)

    ENTITY_REGEXP   = /\A(?<type>\w+) (?<id>\d+)\Z/i
    GOES_TO_REGEXP  = /\Avalue (?<value>\d+) goes to (?<entity>\w+ \d+)\Z/i
    GIVES_TO_REGEXP = /\A(?<from>\w+ \d+) gives low to (?<low>\w+ \d+) and high to (?<high>\w+ \d+)\Z/i

    attr_reader :inputs

    def initialize(inputs)
      @inputs = inputs
    end

    def call
      result = Result.new([], [])

      inputs.each do |input|
        if operation = deserialize(input)
          result.operations << operation
        else
          result.errors << Error.new("Invalid input: #{input}")
        end
      end

      result
    end

    private

    def deserialize(line)
      case line
      when GOES_TO_REGEXP
        match = $~
        to    = entity(match[:entity]) or return nil

        GoesToOperation.new(value: $~[:value].to_i, to: to)
      when GIVES_TO_REGEXP
        match = $~

        from    = entity(match[:from]) or return nil
        low_to  = entity(match[:low])  or return nil
        high_to = entity(match[:high]) or return nil

        GivesToOperation.new(from: from, low_to: low_to, high_to: high_to)
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
      when 'bot'    then Bot
      when 'output' then Output
      else nil
      end
    end
  end
end
