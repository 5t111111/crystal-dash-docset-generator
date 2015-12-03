# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crystal/dash/docset/generator/version'

Gem::Specification.new do |spec|
  spec.name          = "crystal-dash-docset-generator"
  spec.version       = Crystal::Dash::Docset::Generator::VERSION
  spec.authors       = ["Hirofumi Wakasugi"]
  spec.email         = ["baenej@gmail.com"]

  spec.summary       = "This is a docset generator for Crystal API documents using Dashing"
  spec.description   = "Run crystal-dash-docset-generator to build the crystal docset from the latest Crystal API documents."
  spec.homepage      = "https://github.com/5t111111/crystal-dash-docset-generator"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "nokogiri", "~> 1.6"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
