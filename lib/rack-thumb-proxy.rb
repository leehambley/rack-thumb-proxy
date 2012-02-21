require 'CGI'
require 'open-uri'
require 'tempfile'
require 'rack-thumb-proxy/version'
require 'rack-thumb-proxy/configuration'

module Rack

  module Thumb

    class Proxy

      class << self

        attr_writer :configuration

        def configure(&block)
          configuration.instance_eval(&block)
          configuration
        end

        def configuration
          @configuration ||= Configuration.new
        end

        def call(env)
          new(env).call
        end

      end

      def initialize(env)
        @env  = env
        @path = env['PATH_INFO']
      end

      def call
        if request_matches?
          validate_signature! &&
          retreive_upstream!  &&
          transform_image!    &&
          format_response!
          response.finish
        else
          [404, {'Content-Length' => 9}, ['Not Found']]
        end
      end

      private

        def handle_request
          response
        end

        def validate_signature!
          true
        end

        def retreive_upstream!
          begin
            open(request_url, 'rb') do |f|
              tempfile.write(f.read)
              tempfile.flush
            end
          rescue
            response.status = 500
            response.body   << $!.message
            return false
          end
          return true
        end

        def format_response!
          response.status = 200
          response.headers["Content-Length"] = transformed_image_file_size_in_bytes
          true
        end

        def tempfile(&bock)
          @_tempfile ||= Tempfile.new(escaped_request_url)
        end

        def transform_image!
          true
        end

        def should_verify_hash_signature?
          configuration.hash_signatures_in_use?
        end

        def configuration
          self.class.configuration
        end

        def request_hash_signature
          @_request_match_data["hash_signature"]
        end

        def request_options
          @_request_match_data["options"]
        end

        def request_gravity
          @_request_match_data["gravity"]
        end

        def request_url
          CGI.unescape(escaped_request_url)
        end

        def escaped_request_url
          @_request_match_data["escaped_url"]
        end

        def request_matches?
          @_request_match_data = @path.match(routing_pattern)
        end

        def transformed_image_file_size_in_bytes
          ::File.size(tempfile)
        end

        # Examples: http://rubular.com/r/oPRK1t31yv
        def routing_pattern
          /^\/(?<hash_signature>[a-z0-9]{10}|)\/?(?<options>(:?[0-9]*x+[0-9]*(?<gravity>c|n|ne|e|s|sw|w|nw|)|))\/?(?<escaped_url>https?.*)$/
        end

        def response
          @_response ||= Rack::Response.new
        end

    end

  end

end
