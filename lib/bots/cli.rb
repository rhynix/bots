module Bots
  class CLI
    EXIT_SUCCESS = 0
    EXIT_FAILURE = 1

    attr_reader :exe, :args, :out

    def initialize(exe, args, out)
      @exe  = exe
      @args = args
      @out  = out
    end

    def run
      unless args.length == 1
        put_usage
        return false
      end

      input      = File.read(args.first)
      operations = OperationsDeserializer.new(input).call
      pre_errors = PreValidator.new(operations).call

      if pre_errors.any?
        put_errors "input", pre_errors
        return false
      end

      state       = Bots::Game.new(operations).run
      post_errors = Bots::PostValidator.new(operations, state).call

      if post_errors.any?
        put_errors "output", post_errors
        return false
      end

      put_outputs(state)

      true
    end

    private

    def put_outputs(state)
      outputs        = state.keys.filter { |entity| entity.is_a?(Output) }
      max_output_len = outputs.map { |output| output.id.to_s.length }.max

      outputs.sort_by(&:id).each do |output|
        output_id = output.id.to_s.rjust(max_output_len)
        values    = state[output].join(", ")

        out.puts "output( #{output_id} ) = #{values}"
      end
    end

    def put_errors(type, errors)
      out.puts "One or more #{type} errors:"

      errors.each do |error|
        out.puts "* #{error.message}"
      end
    end

    def put_usage
      out.puts "usage: #{exe} input-file"
    end
  end
end
