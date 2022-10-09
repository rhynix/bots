# frozen_string_literal: true

require "sinatra/base"
require "timeout"

module Bots
  class Server < Sinatra::Base
    set :default_content_type, :json
    set :port, 8080
    set :env, "production"
    set :bind, "0.0.0.0"

    post "/" do
      content_type :json

      lines        = deserialize(request.body.read) or bad_request
      parse_result = InstructionsParser.new(lines).call

      bad_request parse_result.errors if parse_result.errors.any?

      pre_errors = PreValidator.new(
        input_instructions: parse_result.input_instructions,
        bot_instructions: parse_result.bot_instructions
      ).call
      bad_request pre_errors if pre_errors.any?

      state = Game.new(
        input_instructions: parse_result.input_instructions,
        bot_instructions: parse_result.bot_instructions
      ).run

      post_errors = PostValidator.new(state.world).call
      bad_request post_errors if post_errors.any?

      JSON.dump(serialize_outputs(state))
    end

    private

    def run_game_with_timeout(instructions)
      Game.new(instructions).run
    rescue Timeout::Error
      bad_request "timeout"
    end

    def serialize_outputs(state)
      outputs = state.world
        .filter { |entity| entity.is_a?(Entities::Output) }
        .transform_keys { |output| output.id.to_s }
        .transform_values(&:first)

      {
        log: state.log,
        outputs: outputs
      }
    end

    def deserialize(input)
      input = JSON.parse(input)

      if input_valid?(input)
        input
      else
        nil
      end
    rescue JSON::ParserError
      nil
    end

    def input_valid?(input)
      return false unless input.is_a?(Array)
      return false unless input.all? { |item| item.is_a?(String) }

      true
    end

    def bad_request(error_or_errors = "bad request")
      key      = error_or_errors.is_a?(Array) ? "errors" : "error"
      response = JSON.dump({ key => error_or_errors })

      halt 400, response
    end
  end
end
