task :default => [:build]
task :test => [:build, :install]

task :build do
  `gem build ./hostlist.gemspec`
end

task :install do
  gem = Dir['*.gem'].last
  `sudo gem install #{gem}`
end

task :push do
  gem = Dir['*.gem'].last
  system("gem inabox #{gem}")
end

task :console do
  exec "irb -r hostlist -I ./lib"
end

task :run do
  ruby "-Ilib", 'bin/hostlist'
end
