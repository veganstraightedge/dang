require "helper"

describe "selectors" do
  it "transforms DANG tag#id into HTML tag with an id attribute" do
    Dang::it("<div#awesome lorem and or ipsum div>").must_equal "<div id='awesome'>lorem and or ipsum</div>"
  end

  it "transforms DANG tag.class into HTML tag with a class" do
    Dang::it("<i.pants party i>").must_equal "<i class='pants'>party</i>"
  end

  it "transforms DANG tag#id.class into HTML tag with an id and a class" do
    Dang::it("<s#pants.party woo hoo s>").must_equal "<s id='pants' class='party'>woo hoo</s>"
  end

  it "should merge shorthand and longhand classes" do
    Dang::it("<html#foo.bar[class=snap crackle pop mitch]").must_equal "<html id='foo' class='bar snap crackle pop mitch'>"
  end
end
