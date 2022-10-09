# frozen_string_literal: true

module Bots
  class PostValidator
    attr_reader :world

    def initialize(world)
      @world = world
    end

    def call
      validate_single_value_per_output
    end

    private

    def validate_single_value_per_output
      outputs.flat_map do |output, values|
        next [] if values.length == 1

        values  = values.join(", ")
        message = "#{output} received multiple values: #{values}"

        [Error.new(message)]
      end
    end

    def outputs
      world.filter { |entity| entity.is_a?(Output) }
    end
  end
end
