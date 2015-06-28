Gem::Specification.new do |gem|
  gem.name        = 'hostlist'
  gem.version     = '1.0.1'
  gem.licenses    = ['MIT']
  gem.date        = '2015-06-27'
  gem.summary     = 'Host List Generator'
  gem.description = 'Generates list of hosts based on tags.'
  gem.authors     = ['Zan Loy']
  gem.email       = ['zan.loy@gmail.com']
  gem.homepage    = 'https://github.com/zanloy/hostlist'
  gem.files       = `git ls-files`.split("\n") - %w[.gitignore]
  gem.executables = ['hostlist']

  gem.add_runtime_dependency 'bracecomp', '~> 0.1', '>= 0.1.2'
  gem.add_runtime_dependency 'daybreak', '~> 0.3', '>= 0.3.0'
  gem.add_runtime_dependency 'thor', '~> 0.19', '>= 0.19.1'
end
