# frozen_string_literal: true

module Bots
  class Output
    include Equatable[:id]

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def to_s
      "output(#{id})"
    end
  end
end
