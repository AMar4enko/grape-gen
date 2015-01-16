class Redis
  class Namespace
    def call_with_namespace(command, *args, &block)
      handling = COMMANDS[command.to_s.downcase]

      if handling.nil?
        fail("Redis::Namespace does not know how to handle '#{command}'.")
      end

      (before, after) = handling

      # Add the namespace to any parameters that are keys.
      case before
        when :first
          args[0] = add_namespace(args[0]) if args[0]
        when :all
          args = add_namespace(args)
        when :exclude_first
          first = args.shift
          args = add_namespace(args)
          args.unshift(first) if first
        when :exclude_last
          last = args.pop unless args.length == 1
          args = add_namespace(args)
          args.push(last) if last
        when :exclude_options
          if args.last.is_a?(Hash)
            last = args.pop
            args = add_namespace(args)
            args.push(last)
          else
            args = add_namespace(args)
          end
        when :alternate
          args.each_with_index { |a, i| args[i] = add_namespace(a) if i.even? }
        when :sort
          args[0] = add_namespace(args[0]) if args[0]
          if args[1].is_a?(Hash)
            [:by, :store].each do |key|
              args[1][key] = add_namespace(args[1][key]) if args[1][key]
            end

            args[1][:get] = Array(args[1][:get])

            args[1][:get].each_index do |i|
              args[1][:get][i] = add_namespace(args[1][:get][i]) unless args[1][:get][i] == "#"
            end
          end
        when :eval_style
          # redis.eval() and evalsha() can either take the form:
          #
          #   redis.eval(script, [key1, key2], [argv1, argv2])
          #
          # Or:
          #
          #   redis.eval(script, :keys => ['k1', 'k2'], :argv => ['arg1', 'arg2'])
          #
          # This is a tricky + annoying special case, where we only want the `keys`
          # argument to be namespaced.
          if args.last.is_a?(Hash)
            args.last[:keys] = add_namespace(args.last[:keys])
          else
            args[1] = add_namespace(args[1])
          end
        when :scan_style
          options = (args.last.kind_of?(Hash) ? args.pop : {})
          options[:match] = add_namespace(options.fetch(:match, '*'))
          args << options

          if block
            original_block = block
            block = proc { |key| original_block.call rem_namespace(key) }
          end
      end

      d = EventMachine::DefaultDeferrable.new

      # Dispatch the command to Redis and store the result.
      result = @redis.send(command, *args, &block)

      result.callback do |result|
        case after
          when :all
            result = rem_namespace(result)
          when :first
            result[0] = rem_namespace(result[0]) if result
          when :second
            result[1] = rem_namespace(result[1]) if result
        end
        d.succeed(result)
      end

      d
    end
  end
end