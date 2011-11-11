require 'rubygems'
require 'rake'

task :check_dependencies do
  begin
    require "bundler"
  rescue LoadError
    abort "Samuel uses Bundler to manage development dependencies. Install it with `gem install bundler`."
  end
  system("bundle check") || abort
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false
  test.warning = true
end

task :default => [:check_dependencies, :test]

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
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
end
