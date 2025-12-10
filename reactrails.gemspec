require_relative "lib/reactrails/version"

Gem::Specification.new do |spec|
  spec.name        = "reactrails"
  spec.version     = Reactrails::VERSION
  spec.authors     = ["pioz"]
  spec.email       = ["epilotto@gmx.com"]
  spec.homepage    = "https://github.com/pioz/reactrails"
  spec.summary     = "Integrate React with Rails with esbuild"
  spec.description = "Integrate React with Rails with esbuild and SSR support"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pioz/reactrails"
  spec.metadata["changelog_uri"] = "https://github.com/pioz/reactrails/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.0"
  spec.add_dependency "execjs", ">= 2.10.0"
  spec.add_dependency "rails", ">= 8.1.1"
end
