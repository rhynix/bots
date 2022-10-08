module Bots
  class PostValidator
    attr_reader :operations, :state

    def initialize(operations, state)
      @operations = operations
      @state      = state
    end

    def call
      [
        *validate_no_missing_outputs,
        *validate_no_extra_outputs,
        *validate_single_value_per_output
      ]
    end

    private

    def validate_no_missing_outputs
      missing_values = input_values - output_values.flatten
      missing_values.map do |value|
        AssertionError.new("Input value missing from output: #{value}")
      end
    end

    def validate_no_extra_outputs
      extra_values = output_values.flatten - input_values
      extra_values.map do |value|
        AssertionError.new("Unexpected output value: #{value}")
      end
    end

    def validate_single_value_per_output
      outputs.flat_map do |output, values|
        if values.length == 1
          []
        else
          values  = values.join(", ")
          message = "Output #{output.id} received multiple values: #{values}"

          [AssertionError.new(message)]
        end
      end
    end

    def input_values
      operations.filter { |op| op.is_a?(InputOperation) }.map(&:value)
    end

    def output_values
      outputs.values
    end

    def outputs
      state.slice(*state.keys.filter { |entity| entity.is_a?(Output) })
    end
  end
end
