# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack-thumb-proxy/version', __FILE__)

Gem::Specification.new do |gem|

  gem.authors       = ["Lee Hambley"]
  gem.email         = ["lee.hambley@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rack-thumb-proxy"
  gem.require_paths = ["lib"]

  gem.version       = Rack::Thumb::Proxy::VERSION

  gem.add_dependency 'rack'

  gem.add_development_dependency 'minitest', '~> 2.11'
  gem.add_development_dependency 'webmock', '~> 1.8.0'
  gem.add_development_dependency 'rack-test', '~> 0.6.1'
  gem.add_development_dependency 'dimensions'
  gem.add_development_dependency 'mini_magick'

end
