# coding: utf-8
require File.expand_path("../lib/radius_client/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "radius_client"
  spec.version       = RadiusClient::VERSION
  spec.authors       = %w(Slava\ Kisel)
  spec.email         = %w(slava.kisel@flatstack.com)

  spec.summary       = "Ruby wrapper for freeradius server"
  spec.description   = "Ruby wrapper for freeradius server"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    fail "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|templates)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib)

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "simplecov", "~> 0.11.2"
  spec.add_development_dependency "minitest-reporters", "1.1.9"

  spec.add_runtime_dependency "ipaddr_extensions", "1.0.2"
end
