# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack-thumb-proxy/version', __FILE__)

Gem::Specification.new do |gem|

  gem.authors       = ["Lee Hambley"]
  gem.email         = ["lee.hambley@gmail.com"]
  gem.description   = %q{ Rack middleware for resizing proxied requests for images which don't reside on your own servers. }
  gem.summary       = %q{ For more information see https://github.com/leehambley/rack-thumb-proxy }
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rack-thumb-proxy"
  gem.require_paths = ["lib"]

  gem.version       = Rack::Thumb::Proxy::VERSION

  gem.add_dependency 'mapel'
  gem.add_dependency 'rack'

  gem.add_development_dependency 'minitest', '~> 2.11'
  gem.add_development_dependency 'webmock', '~> 1.8.0'
  gem.add_development_dependency 'rack-test', '~> 0.6.1'
  gem.add_development_dependency 'dimensions'

end
