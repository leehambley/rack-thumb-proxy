require "rack-thumb-proxy/version"

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

      end


      class Configuration

        attr_accessor :key_length
        attr_accessor :mount_point

        attr_reader   :option_labels

        def initialize
          @secret        = nil
          @key_length    = 10
          @mount_point   = '/'
          @option_labels = {}
        end

        def mount_point(new_mount_point = nil)
          @mount_point = new_mount_point if new_mount_point
          return @mount_point
        end

        def key_length(new_key_length = nil)
          @key_length = new_key_length if new_key_length
          return @key_length
        end

        def secret(new_secret = nil)
          @secret = new_secret if new_secret
          return @secret
        end

        def option_label(label, options)
          option_labels.merge!(label.to_sym => options)
        end

        def hash_signatures_in_use?
          !!@secret
        end

      end

    end

  end
end