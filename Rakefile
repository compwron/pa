require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs.push 'test'
  t.pattern = 'test/**/*_test.rb'
end

task :default => [:spec, :test]


