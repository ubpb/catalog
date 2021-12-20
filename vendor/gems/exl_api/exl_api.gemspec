# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exl_api/version'

Gem::Specification.new do |spec|
  spec.name          = "exl_api"
  spec.version       = ExlApi::VERSION
  spec.authors       = ["René Sprotte"]
  spec.summary       = %q{A ruby wrapper for the Ex Libris Rest APIs}
  spec.homepage      = "http://github.com/ubpb/exl_api"

  spec.files          = Dir['lib/**/*.rb']
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "> 6"
  spec.add_dependency "rest-client", "~> 2.1"
  spec.add_dependency "oj", "~> 3.11"
  spec.add_dependency "nokogiri", "~> 1.11"
end
