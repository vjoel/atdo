require 'rake'
require 'rake/testtask'

desc "Run tests"
Rake::TestTask.new :test do |t|
  t.libs << "lib"
  t.test_files = FileList["test/*.rb"]
end

desc "Run benchmarks"
Rake::TestTask.new :bench do |t|
  t.libs << "lib"
  t.test_files = FileList["bench/*.rb"]
end
