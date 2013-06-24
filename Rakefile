require "rubygems"
require "hoe"

Hoe.plugins.delete :rubyforge
Hoe.plugin :doofus, :git

Hoe.spec "dang" do
  developer "Shane Becker", "veganstraightedge@gmail.com"

  self.extra_rdoc_files =  Dir["*.rdoc"]
  self.history_file     =  "History.md"
  self.readme_file      =  "README.md"
  self.licenses         << "PUBLIC DOMAIN"
  self.licenses         << "CC0"
end

task :parser do
  sh "ruby -I../kpeg/lib ../kpeg/bin/kpeg -o lib/dang/parser.rb -f -n Dang::Parser -s lib/dang/parser.kpeg"
end

$:.unshift "."
$:.unshift "./lib"

task :default => :spec

task :spec do
  Dir[File.dirname(__FILE__) + "/spectory/**/*_spec.rb"].each do |path|
    require path
  end

  Minitest.autorun
end
