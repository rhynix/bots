module Bots
  class CLI
    Result = Struct.new(:success?, :out)

    attr_reader :exe, :args

    def initialize(exe, args)
      @exe  = exe
      @args = args
    end

    def run
      return failure("usage: #{exe} input-file") unless args.length == 1

      input  = File.read(args.first)
      inputs = input.lines.map(&:strip)

      input_result = OperationsDeserializer.new(inputs).call
      input_errors = input_result.errors

      return failure(format_errors("input", input_errors)) if input_errors.any?

      operations = input_result.operations
      pre_errors = PreValidator.new(operations).call

      return failure(format_errors("input", pre_errors)) if pre_errors.any?

      state       = Game.new(operations).run
      post_errors = PostValidator.new(operations, state[:current]).call

      return failure(format_errors("output", post_errors)) if post_errors.any?

      return success(format_state(state))
    end

    private

    def success(out)
      Result.new(true, out)
    end

    def failure(out)
      Result.new(false, out)
    end

    def format_state(state)
      log     = state[:log]
      current = state[:current]

      out = String.new

      out << "log:\n"

      log.each do |log_item|
        out << "  #{log_item.to_s}\n"
      end

      outputs        = current.keys.filter { |entity| entity.is_a?(Output) }
      max_output_len = outputs.map { |output| output.id.to_s.length }.max

      out << "outputs:\n"

      outputs.sort_by(&:id).each do |output|
        output_id = output.id.to_s.rjust(max_output_len)
        values    = current[output].join(", ")

        out << "  output( #{output_id} ) = #{values}\n"
      end

      out
    end

    def format_errors(type, errors)
      out = String.new
      out << "One or more #{type} errors:\n"

      errors.each do |error|
        out << "* #{error.message}\n"
      end

      out
    end

    def put_usage
    end
  end
end
