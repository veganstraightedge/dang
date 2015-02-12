# -*- encoding: utf-8 -*-
# stub: dang 2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "dang"
  s.version = "2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Shane Becker"]
  s.date = "2015-02-12"
  s.description = "Dang is a Ruby templating language.\nIt uses angle brackets and CSS syntax.\nSomewhere between ERB and Haml."
  s.email = ["veganstraightedge@gmail.com"]
  s.executables = ["dang"]
  s.extra_rdoc_files = ["History.md", "Manifest.txt", "README.md"]
  s.files = [".hoeignore", "Gemfile", "Gemfile.lock", "History.md", "Manifest.txt", "README.md", "Rakefile", "bin/dang", "dang.gemspec", "lib/dang.rb", "lib/dang/dang.rb", "lib/dang/parser.kpeg", "lib/dang/parser.rb", "lib/dang/rails.rb", "specs/attribute_spec.rb", "specs/comment_spec.rb", "specs/conditional_comment_spec.rb", "specs/data_attribute_spec.rb", "specs/doctype_spec.rb", "specs/embedded_ruby_spec.rb", "specs/experiments/array_classes_spec.rb", "specs/experiments/filters/markdown_spec.rb", "specs/experiments/hash_attribute_spec.rb", "specs/experiments/script_exception_spec.rb", "specs/experiments/style_exception_spec.rb", "specs/file_spec.rb", "specs/files/iamshane-com.html", "specs/files/iamshane-com.html.dang", "specs/filter_spec.rb", "specs/helper.rb", "specs/interpolation_spec.rb", "specs/sanity_spec.rb", "specs/script_spec.rb", "specs/selector_spec.rb", "specs/style_spec.rb", "specs/tag_spec.rb", "specs/well_formedness_spec.rb", "specs/whitespace_spec.rb"]
  s.homepage = "https://github.com/veganstraightedge/dang"
  s.licenses = ["PUBLIC DOMAIN", "CC0"]
  s.rdoc_options = ["--main", "README.md"]
  s.rubygems_version = "2.2.2"
  s.summary = "Dang is a Ruby templating language"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.12"])
    else
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe>, ["~> 3.12"])
    end
  else
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe>, ["~> 3.12"])
  end
end
