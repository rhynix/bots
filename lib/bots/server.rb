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

      lines  = deserialize(request.body.read) or bad_request
      result = run_with_timeout(Runner.new(lines))

      if result.success?
        JSON.dump(result.out.as_json)
      else
        bad_request(result.out.as_json)
      end
    end

    private

    def run_with_timeout(runner)
      runner.run
    rescue Timeout::Error
      bad_request({ error: "timeout" })
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

    def bad_request(body = { error: "bad request" })
      halt 400, JSON.dump(body)
    end
  end
end
