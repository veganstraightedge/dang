require "helper"
require "tags"

describe Tag do
  it "transforms DANG tag to HTML tag" do
    Dang::it("<b BOLD b>").must_equal "<b>BOLD</b>"
  end
  
  it "transforms DANG self closing tag to self closing HTML tag" do
    Dang::it("<img[src=foo.png] />").must_equal "<img src='foo.png' />"
  end

  it "transforms DANG tags nested inline to inline nested HTML tags" do
    Dang::it("<h1 <a[href=/] Home a> h1>").must_equal "<h1><a href='/'>Home</a></h1>"
  end

  it "transforms DANG tags nested multiline to multiline nested HTML tags" do
    dang = "
<header
  <hgroup
    <h1 Dang Lang h1>
    <h2 It's the angle of the dangle h2>
  </hgroup
header>"

    html = "
<header>
  <hgroup>
    <h1>Dang Lang</h1>
    <h2>It's the angle of the dangle</h2>
  </hgroup>
</header>"

    Dang::it(dang).must_equal html
  end
end
