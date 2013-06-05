require "spectory/helper"

describe "tags" do
  it "transforms DANG tag to HTML tag with no content" do
    Dang.it("<b b>").must_equal "<b></b>"
  end

  it "transforms DANG tag to HTML tag" do
    Dang.it("<b BOLD b>").must_equal "<b>BOLD</b>"
  end

  it "transforms DANG self closing tag to self closing HTML tag" do
    Dang.it("<img[src=foo.png] />").must_equal "<img src='foo.png' />"
  end

  it "transforms DANG self closing tag with multiple attributes to HTML" do
    Dang.it("<img[src=foo.png][alt=rock] />").must_equal "<img src='foo.png' alt='rock' />"
  end

  it "transforms DANG self closing with no attributes tag to HTML" do
    Dang.it("<img />").must_equal "<img />"
  end

  it "transforms DANG self closing with no attributes tag to HTML" do
    Dang.it("<img#id />").must_equal "<img id='id' />"
  end

  it "transforms DANG tags with an attribute and an explicit closer" do
    Dang.it("<a[href=/] Home a>").must_equal "<a href='/'>Home</a>"
  end

  it "transforms DANG tags nested inline to inline nested HTML tags" do
    Dang.it("<h1 <a[href=/] Home a> h1>").must_equal "<h1><a href='/'>Home</a></h1>"
  end

  it "transforms DANG tags nested inline to inline nested HTML tags wrapped in text" do
    Dang.it("<h1 STUFF <a[href=/] Home a> MORE STUFF h1>").must_equal "<h1>STUFF <a href='/'>Home</a> MORE STUFF</h1>"
  end

  it "transforms DANG tags nested multiline to multiline nested HTML tags" do
    dang = "
<header
  <hgroup
    <h1 Dang Lang h1>
    <h2 It's the angle of the dangle h2>
  hgroup>
header>"

    html =
"<header>
  <hgroup>
    <h1>Dang Lang</h1>
    <h2>It's the angle of the dangle</h2>
  </hgroup>
</header>"

    Dang.it(dang).must_equal html
  end

  it "transforms sibling root tags" do
    Dang.it("<b BOLD b><i ME i>").must_equal "<b>BOLD</b><i>ME</i>"
  end

  it "transforms sibling root tags with significant whitespace" do
    Dang.it("<b BOLD b>              <i ME i>").must_equal "<b>BOLD</b>              <i>ME</i>"
  end
end
