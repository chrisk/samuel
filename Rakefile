require 'rubygems'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false
  test.warning = true
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "samuel"
    gem.version = "0.3.2"
    gem.summary = %Q{An automatic logger for HTTP requests in Ruby}
    gem.description = %Q{An automatic logger for HTTP requests in Ruby, supporting the Net::HTTP and HTTPClient client libraries.}
    gem.email = "chris@kampers.net"
    gem.homepage = "http://github.com/chrisk/samuel"
    gem.authors = ["Chris Kampmeier"]
    gem.rubyforge_project = "samuel"
    gem.add_development_dependency "shoulda"
    gem.add_development_dependency "mocha"
    gem.add_development_dependency "httpclient"
    gem.add_development_dependency "fakeweb"
  end

  task :test => :check_dependencies
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.rcov_opts << "--sort coverage"
    test.rcov_opts << "--exclude gems"
    test.verbose = false
    test.warning = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: gem install rcov"
  end
end

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: gem install yard"
  end
end
