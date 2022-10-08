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

      inputs             = deserialize(request.body.read) or bad_request
      deserialize_result = OperationsParser.new(inputs).call

      bad_request deserialize_result.errors if deserialize_result.errors.any?

      operations = deserialize_result.operations
      pre_errors = PreValidator.new(operations).call

      bad_request pre_errors if pre_errors.any?

      state       = run_game_with_timeout(operations)
      post_errors = PostValidator.new(operations, state.world).call

      bad_request post_errors if post_errors.any?

      JSON.dump(serialize_outputs(state))
    end

    private

    def run_game_with_timeout(operations)
      Game.new(operations).run
    rescue Timeout::Error
      bad_request "timeout"
    end

    def serialize_outputs(state)
      outputs = state.world
        .filter { |entity| entity.is_a?(Output) }
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
