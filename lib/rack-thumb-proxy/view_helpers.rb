module Rack
  module Thumb
    class Proxy
      module ViewHelpers

        def proxied_image_url(image_url, options = nil)

          if rack_thumb_proxy_hash_signatures_enabled?
            signature = hash_signature_for(image_url, options)
          end

          options           = rack_thumb_proxy_options_to_s(options)
          escaped_image_url = escape_image_url(image_url)
          mount_point       = rack_thumb_proxy_configuration.mount_point

          mount_point + [signature, options, escaped_image_url].compact.join("/")

        end

        def hash_signature_for(image_url, options = nil)
          return nil unless rack_thumb_proxy_hash_signatures_enabled?
          key_length = rack_thumb_proxy_configuration.key_length
          secret     = rack_thumb_proxy_configuration.secret
          ('%s\t%s\t%s' % [secret, options, escape_image_url(image_url)])[0..key_length-1]
        end

        private

          def escape_image_url(image_url)
            CGI.escape(image_url)
          end

          def rack_thumb_proxy_options_to_s(options = nil)
            return nil if options.nil?
            if options.is_a?(String)
              options
            elsif options.is_a?(Hash)
              sprintf("%sx%s%s", options[:width], options[:height], options[:gravity])
            else
              raise RuntimeError, 'Not implemented yet, see the TODO in README.md'
            end
          end

          def rack_thumb_proxy_configuration
            Rack::Thumb::Proxy.configuration
          end

          def rack_thumb_proxy_hash_signatures_enabled?
            rack_thumb_proxy_configuration.hash_signatures_in_use?
          end

      end
    end
  end
end
