require "spectory/helper"

describe "style tags" do
  it "treat style tags special" do
    dang = "
<style
body {
  background: red;
}

p:after {
  content: '}';
}
style>
"

    html = "<style>
body {
  background: red;
}

p:after {
  content: '}';
}
</style>"

    Dang.it(dang).must_equal html
  end

  it "skips css that looks like a closing dang tag" do
    Dang.it("<style abbr:after { content: ' style>' } style>").must_equal "<style>abbr:after { content: ' style>' } </style>"
    Dang.it('<style abbr:after { content: " style>" } style>').must_equal '<style>abbr:after { content: " style>" } </style>'
  end
end
