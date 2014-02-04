require 'cgi'
require 'open-uri'
require 'tempfile'
require 'rack-thumb-proxy/version'
require 'rack-thumb-proxy/configuration'
require 'rack-thumb-proxy/view_helpers'

require 'rack-thumb-proxy/railtie' if defined?(Rails::Railtie)

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
          [404, {'Content-Length' => 9.to_s, 'Content-Type' => 'text/plain'}, ['Not Found']]
        end
      end

      private

        def validate_signature!
          true
        end

        def retreive_upstream!
          open(request_url, 'rb') do |f|
            tempfile.binmode
            tempfile.write(f.read)
            tempfile.flush
          end
          return true
        end

        def format_response!
          response.status = 200
          response.headers["Content-Type"] = mime_type_from_request_url
          response.headers["Content-Length"] = transformed_image_file_size_in_bytes.to_s
          response.body << read_tempfile
          true
        end

        def read_tempfile
          tempfile.rewind
          tempfile.read
        end

        def tempfile
          @_tempfile ||= Tempfile.new('rack_thumb_proxy')
        end

        def tempfile_path
          tempfile.path
        end

        def transform_image!

          return true unless should_resize?

          require 'mapel'

          width, height   = dimensions_from_request_options
          owidth, oheight = dimensions_from_tempfile

          width  = [width,  owidth].min  if width
          height = [height, oheight].min if height

          cmd = Mapel(tempfile_path)

          if width && height
            cmd.gravity(request_gravity)
            cmd.resize!(width, height)
          else
            cmd.resize(width, height, 0, 0, '>')
          end

          cmd.to(tempfile_path).run

          true

        end

        def should_resize?
          !request_options.empty?
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
          {
            'nw' => :northwest,
            'n'  => :north,
            'ne' => :northeast,
            'w'  => :west,
            'c'  => :center,
            'e'  => :east,
            'sw' => :southwest,
            's'  => :south,
            'se' => :southeast
          }.fetch(request_gravity_shorthand, :center)
        end

        def request_gravity_shorthand
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

        def witdh_from_tempfile
          dimensions_from_tempfile.first
        end

        def height_from_tempfile
          dimensions_from_tempfile.last
        end

        def dimensions_from_tempfile
          require 'mapel' unless defined?(Mapel)
          Mapel.info(tempfile_path)[:dimensions]
        end

        def width_from_request_options
          dimensions_from_request_options.first
        end

        def height_from_request_options
          dimensions_from_request_options.last
        end

        def dimensions_from_request_options
          width, height = request_options.split('x').map(&:to_i).collect { |dim| dim == 0 ? nil : dim }
          [width, height]
        end

        def transformed_image_file_size_in_bytes
          ::File.size(tempfile_path)
        end

        # Examples: http://rubular.com/r/oPRK1t31yv
        def routing_pattern
          /^\/(?<hash_signature>[a-z0-9]{10}|)\/?(?<options>(:?[0-9]*x+[0-9]*|))(?<gravity>c|n|ne|e|s|sw|w|nw|)\/?(?<escaped_url>https?.*)$/
        end

        def response
          @_response ||= Rack::Response.new
        end

        def write_error_to_response!
          response.status = 500
          response.headers['Content-Type'] = 'text/plain'
          response.body   << $!.message
          response.body   << "\n\n"
          response.body   << $!.backtrace.join("\n")
        end

        def request_url_file_extension
          ::File.extname(request_url)
        end

        def mime_type_from_request_url
          {
            '.png'  => 'image/png',
            '.gif'  => 'image/gif',
            '.jpg'  => 'image/jpeg',
            '.jpeg' => 'image/jpeg'
          }.fetch(request_url_file_extension, 'application/octet-stream')
        end

    end

  end

end
