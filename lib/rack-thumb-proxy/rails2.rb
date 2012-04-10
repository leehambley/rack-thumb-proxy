module Rack
  module Thumb
    class Proxy
      class Rails2
        def initialize(app, options = {})
          @upstream = app
          @downstream = Rack::Thumb::Proxy
          @downstream.configure do
            mount_point options[:mount_point] if options.has_key?(:mount_point)
          end
        end

        def call(env)
          regex = %r!^#{@downstream.configuration.mount_point}!
          if env["PATH_INFO"] =~ regex
            env["PATH_INFO"].sub! regex, ""
            @downstream.call env
          else
            @upstream.call env
          end
        end
      end
    end
  end
end
