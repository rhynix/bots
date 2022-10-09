# frozen_string_literal: true

module Bots
  class Errors
    attr_reader :type, :errors

    def initialize(type, errors)
      @type   = type
      @errors = errors
    end

    def formatted
      out = String.new
      out << "#{type} errors:\n"

      errors.each do |error|
        out << "  #{error}\n"
      end

      out
    end

    def as_json
      { "errors" => errors.map(&:to_s) }
    end
  end
end
