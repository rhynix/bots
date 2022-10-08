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

    def format
      out = String.new
      out << "log:\n"

      log.each do |log_item|
        out << "  #{log_item.to_s}\n"
      end

      outputs        = world.keys.filter { |entity| entity.is_a?(Output) }
      max_output_len = outputs.map { |output| output.id.to_s.length }.max

      out << "outputs:\n"

      outputs.sort_by(&:id).each do |output|
        output_id = output.id.to_s.rjust(max_output_len)
        values    = world[output].join(", ")

        out << "  output( #{output_id} ) = #{values}\n"
      end

      out
    end
  end
end
