module Bots
  class Output
    include Equatable[:id]

    attr_reader :id

    def initialize(id)
      @id = id
    end
  end
end
