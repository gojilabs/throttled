
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "throttled/version"

Gem::Specification.new do |spec|
  spec.name          = "throttled"
  spec.version       = Throttled::VERSION
  spec.authors       = ["Adam Sumner"]
  spec.email         = ["adamsumner@gmail.com"]

  spec.summary       = %q{throttling made easy}
  spec.description   = %q{Add throttling rules according to the service, adjust those rules during runtime as they may change, record each throttled action, and back off when the quota has been exceeded.}
  spec.homepage      = "https://www.gojilabs.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = 'https://gems.gojilabs.com'
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '>= 4.0.0'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency 'factory_bot', '~> 4.10'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'timecop', '~> 0.9'
end
