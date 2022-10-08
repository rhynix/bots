# frozen_string_literal: true

module Bots
  class GameState
    attr_reader :log, :world

    def initialize(log: [], world: {})
      @log   = log
      @world = world
    end

    def add_to_log(*updates)
      self.class.new(log: [*log, *updates], world: world)
    end

    def update_world(updates)
      self.class.new(log: log, world: { **world, **updates })
    end

    def formatted
      out = String.new
      out << "log:\n"

      log.each do |log_item|
        out << "  #{log_item.to_s}\n"
      end

      out << "world:\n"

      world.each do |entity, values|
        out << "  #{entity} = #{values.join(", ")}\n" if values.any?
      end

      out
    end
  end
end
