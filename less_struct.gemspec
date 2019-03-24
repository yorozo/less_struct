
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "less_struct/version"

Gem::Specification.new do |spec|
  spec.name          = "less_struct"
  spec.version       = LessStruct::VERSION
  spec.authors       = ["yorozo"]
  spec.email         = ["46701785+yorozo@users.noreply.github.com"]

  spec.summary       = %q{LessStruct - less open OpenStruct}
  spec.description   = %q{Unlike OpenStruct, LessStruct raises NoMethodError when you try to read un-assigned attributes, and that leads to less bugs in your code. Plus, LessStruct supports ease-of-use data caching on Redis.}
  spec.homepage      = "https://github.com/yorozo/less_struct"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_runtime_dependency "redis", ">= 3.0.4"
  # spec.add_runtime_dependency "activesupport", ">= 3", "< 6"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
