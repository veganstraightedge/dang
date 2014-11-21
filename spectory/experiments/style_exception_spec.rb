require "spectory/helper"

# describe "style tags" do
#   it "skips css that looks like a closing dang tag" do
#     Dang.it("<style abbr:after { content: ' style>' } style>").must_equal "<style>abbr:after { content: ' style>' } </style>"
#     Dang.it('<style abbr:after { content: " style>" } style>').must_equal '<style>abbr:after { content: " style>" } </style>'
#   end
# end
