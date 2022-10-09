# frozen_string_literal: true

module Bots
  module Entities
    class Bot
      include Equatable[:id]

      attr_reader :id

      def initialize(id)
        @id = id
      end

      def to_s
        "bot(#{id})"
      end
    end
  end
end
