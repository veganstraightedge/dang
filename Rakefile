require "rubygems"
require "hoe"

Hoe.plugins.delete :rubyforge
Hoe.plugin :doofus, :git, :minitest

Hoe.spec "dang" do
  developer "Shane Becker", "veganstraightedge@example.com"

  self.extra_rdoc_files = Dir["*.rdoc"]
  self.history_file     = "History.md"
  self.readme_file      = "README.md"
end

task :parser do
  sh "ruby -I../kpeg/lib ../kpeg/bin/kpeg -o lib/dang/parser.rb -f -n Dang::Parser -s lib/dang/parser.kpeg"
end
