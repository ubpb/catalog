# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alma_api/version'

Gem::Specification.new do |spec|
  spec.name          = "alma_api"
  spec.version       = AlmaApi::VERSION
  spec.authors       = ["René Sprotte"]
  spec.summary       = %q{A ruby wrapper for the Ex Libris Alma Rest APIs}
  spec.homepage      = "http://github.com/ubpb/alma_api"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "> 5"
  spec.add_dependency "rest-client", "~> 2.1"
  spec.add_dependency "oj", "~> 3.0"
  spec.add_dependency "nokogiri", "~> 1.10"
end
