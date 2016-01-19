# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shotgun/version'

Gem::Specification.new do |spec|
  spec.name          = "shotgun"
  spec.version       = Shotgun::VERSION
  spec.authors       = ["davidkelley"]
  spec.email         = ["david.james.kelley@gmail.com"]
  spec.summary       = %q{Uses Hosted DNS Domains to dynamically discover services on-demand.}
  spec.description   = %q{Uses Hosted DNS Domains to dynamically discover services on-demand. Can either be used as a standalone gem, or through a Docker Container.}
  spec.homepage      = "http://shotgun.stockflare.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.0.0")

  spec.add_development_dependency %q<bundler>, ['~> 1.6']
  spec.add_development_dependency %q<rake>, ['~> 10.3']
  spec.add_development_dependency %q<rspec>, ['~> 3.0']
  spec.add_development_dependency %q<faker>, ['~> 1.4']
  spec.add_development_dependency %q<yard>, ['~> 0.8']
  spec.add_development_dependency %q<dotenv>, ['~> 2.0']
  spec.add_development_dependency %q<rubocop>, ['~> 0.32']
end
