require 'rubygems'
require 'bundler/setup'

require 'cgi'

require 'rack-thumb-proxy'

require 'rack/test'

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/mock'

require 'webmock/minitest'

WebMock.disable_net_connect!

require 'ruby-debug'
