module Rack
  module Thumb
    class Proxy

      class Configuration

        attr_reader   :cache_control_headers
        attr_reader   :option_labels

        def initialize
          initialize_defaults!
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

        def initialize_defaults!
          @secret                = nil
          @key_length            = 10
          @mount_point           = '/'
          @option_labels         = {}
          @cache_control_headers = {'Cache-Control' => 'max-age=86400, public, must-revalidate'}
        end
        alias :reset_defaults! :initialize_defaults!
        private :initialize_defaults!

      end

    end

  end

end
