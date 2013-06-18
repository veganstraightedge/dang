require "spectory/helper"

describe "selectors" do
  it "transforms Dang tag#id into HTML tag with an id attribute" do
    Dang.it("<div#awesome lorem and or ipsum div>").must_equal "<div id='awesome'>lorem and or ipsum</div>"
  end

  it "transforms Dang self closing tag with multiple attributes to HTML" do
    Dang.it("<link[href=http://sbb.me][rel=shorturl][type=text/html] />").must_equal "<link href='http://sbb.me' rel='shorturl' type='text/html' />"
  end
  it "transforms Dang self closing tag with an ID and multiple attributes to HTML" do
    Dang.it("<link#short_url[href=http://sbb.me][rel=shorturl][type=text/html] />").must_equal "<link id='short_url' href='http://sbb.me' rel='shorturl' type='text/html' />"
  end

  it "transforms Dang tag.class into HTML tag with a class" do
    Dang.it("<i.pants party i>").must_equal "<i class='pants'>party</i>"
  end

  it "transforms Dang tag#id.class into HTML tag with an id and a class" do
    Dang.it("<s#pants.party woo hoo s>").must_equal "<s class='party' id='pants'>woo hoo</s>"
  end

  it "should merge shorthand and longhand classes" do
    Dang.it("<html#foo.bar[class=snap crackle pop mitch] things html>").must_equal "<html class='bar snap crackle pop mitch' id='foo'>things</html>"
  end
end
