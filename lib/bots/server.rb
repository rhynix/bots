require "sinatra/base"

module Bots
  class Server < Sinatra::Base
    set :default_content_type, :json
    set :port, 8080
    set :env, "production"
    set :bind, "0.0.0.0"

    post "/" do
      content_type :json

      inputs             = deserialize(request.body.read) or bad_request
      deserialize_result = OperationsDeserializer.new(inputs).call

      if deserialize_result.errors.any?
        bad_request deserialize_result.errors
      end

      operations = deserialize_result.operations
      pre_errors = PreValidator.new(operations).call

      if pre_errors.any?
        bad_request pre_errors
      end

      state       = Game.new(operations).run
      post_errors = PostValidator.new(operations, state).call

      if post_errors.any?
        bad_request post_errors
      end

      JSON.dump(serialize_outputs(state))
    end

    private

    def serialize_outputs(state)
      outputs = state.keys.filter { |entity| entity.is_a?(Output) }
      result  = state.slice(*outputs)

      result
        .transform_keys { |output| output.id.to_s }
        .transform_values(&:first)
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

    def bad_request(error = "bad request")
      halt 400, JSON.dump({ "error" => error })
    end
  end
end
