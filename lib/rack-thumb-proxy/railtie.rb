module Rack
  module Thumb
    class Proxy
      class Railtie < Rails::Railtie
        initializer "rack-thumb-proxy.view_helpers" do
          ActionView::Base.send :include, ViewHelpers
        end
      end
    end
  end
end
