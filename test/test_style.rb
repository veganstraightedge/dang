require 'helper'

describe "style" do
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

    html = "
<style>
body {
  background: red;
}

p:after {
  content: '}';
}
<style>
"

    Dang::it(dang).must_equal html
  end
end