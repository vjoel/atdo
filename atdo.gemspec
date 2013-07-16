Gem::Specification.new do |s|
  s.name = "atdo"
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0")
  s.authors = ["Joel VanderWerf"]
  s.date = "2013-07-16"
  s.description = "At time, do code."
  s.email = "vjoel@users.sourceforge.net"
  s.extra_rdoc_files = ["README.md", "COPYING"]
  s.files = Dir[
    "README.md", "COPYING", "Rakefile",
    "lib/**/*.rb",
    "test/**/*.rb"
  ]
  s.test_files = Dir["test/*.rb"]
  s.homepage = "https://github.com/vjoel/atdo"
  s.license = "BSD"
  s.rdoc_options = ["--quiet", "--line-numbers", "--inline-source", "--title", "atdo", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.summary = "Schedule code to be executed at specified time."
end
