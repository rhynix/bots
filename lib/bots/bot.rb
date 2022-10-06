module Bots
  class Bot
    include Equatable[:id]

    attr_reader :id

    def initialize(id)
      @id = id
    end
  end
end
