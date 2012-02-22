require 'rubygems'
require 'bundler/setup'

require 'cgi'

require 'rack-thumb-proxy'

require 'rack/test'

require 'dimensions'

require 'digest/md5'

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/mock'

require 'webmock/minitest'

WebMock.disable_net_connect!

require 'ruby-debug'
require 'mapel'

class ViewHelperSurrogate
  include Rack::Thumb::Proxy::ViewHelpers
end
