require 'helper'

describe "Syntax" do
  it "should transform DANG tag to HTML tag" do
    Syntax::transform("<b BOLD b>").must_equal "<b>BOLD</b>"
  end

  it "should transform DANG tag#id into HTML tag with an id attribute" do
    Syntax::transform("<div#awesome lorem and or ipsum div>").must_equal "<div id='awesome'>lorem and or ipsum</div>"
  end

  it "should transform DANG tag.class into HTML tag with a class" do
    Syntax::transform("<i.pants party i>").must_equal "<i class='pants'>party</i>"
  end

  it "should transform DANG tag#pants.party into HTML tag with an id and a class" do
    Syntax::transform("<s#pants.party woo hoo s>").must_equal "<s id='pants' class='party'>woo hoo</s>"
  end

  it "should transform DANG tag[attr=value] into HTML tag with an attribute and value" do
    Syntax::transform("<time[datetime=1979-09-18] a while ago >").must_equal "<time datetime='2010-09-18'>a while ago</time>"
  end

  it "should transform DANG self closing tag to self closing HTML tag" do
    Syntax::transform("<img[src=foo.png] />").must_equal "<img src='foo.png' />"
  end

  it "should transform inline nested DANG tags to inline nested HTML tags" do
    Syntax::transform("<h1 <a[href=/] Home a> h1>").must_equal "<h1><a href='/'>Home</a></h1>"
  end
end
