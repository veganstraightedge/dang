# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "dang"
  s.version = "1.0.0.rc6"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Becker"]
  s.date = "2013-08-09"
  s.description = "Dang is a Ruby templating language\nIt uses angle brackets and CSS syntax.\nSomewhere between ERB and Haml."
  s.email = ["veganstraightedge@gmail.com"]
  s.executables = ["dang"]
  s.extra_rdoc_files = ["Manifest.txt"]
  s.files = [".autotest", ".gitignore", ".hoeignore", ".travis.yml", "Gemfile", "Gemfile.lock", "History.md", "Manifest.txt", "README.md", "Rakefile", "TODO.md", "bin/dang", "dang.gemspec", "lib/dang.rb", "lib/dang/dang.rb", "lib/dang/parser.kpeg", "lib/dang/parser.rb", "lib/dang/rails.rb"]
  s.homepage = "https://github.com/veganstraightedge/dang"
  s.licenses = ["PUBLIC DOMAIN", "CC0"]
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "dang"
  s.rubygems_version = "2.0.3"
  s.summary = "Dang is a Ruby templating language It uses angle brackets and CSS syntax"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<hoe>, ["~> 3.5"])
    else
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<hoe>, ["~> 3.5"])
    end
  else
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<hoe>, ["~> 3.5"])
  end
end
