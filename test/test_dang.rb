require 'helper'

describe Dang do
  it "should transform DANG tag to HTML tag" do
    Dang::it("<b BOLD b>").must_equal "<b>BOLD</b>"
  end

  it "should transform DANG tag#id into HTML tag with an id attribute" do
    Dang::it("<div#awesome lorem and or ipsum div>").must_equal "<div id='awesome'>lorem and or ipsum</div>"
  end

  it "should transform DANG tag.class into HTML tag with a class" do
    Dang::it("<i.pants party i>").must_equal "<i class='pants'>party</i>"
  end

  it "should transform DANG tag#pants.party into HTML tag with an id and a class" do
    Dang::it("<s#pants.party woo hoo s>").must_equal "<s id='pants' class='party'>woo hoo</s>"
  end

  it "should transform DANG tag[attr=value] into HTML tag with an attribute and value" do
    Dang::it("<time[datetime=1979-09-18] a while ago >").must_equal "<time datetime='2010-09-18'>a while ago</time>"
  end

  it "should transform DANG self closing tag to self closing HTML tag" do
    Dang::it("<img[src=foo.png] />").must_equal "<img src='foo.png' />"
  end

  it "should transform inline nested DANG tags to inline nested HTML tags" do
    Dang::it("<h1 <a[href=/] Home a> h1>").must_equal "<h1><a href='/'>Home</a></h1>"
  end

  it "should transform multiline nested DANG to multiline nested HTML tags" do
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

    Dang::it(dang).must_equal html.strip
  end

  describe "doctype" do
    it "should transform !!! into doctype html" do
      Dang::it("!!!").must_equal       "<!doctype html>"
      Dang::it("!!! html5").must_equal "<!doctype html>"
    end

    it "should transform HTML4 doctypes" do
      Dang::it("!!! html4").must_equal              '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
      Dang::it("!!! html4 transitional").must_equal '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
      Dang::it("!!! html4 strict").must_equal       '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
      Dang::it("!!! html4 frameset").must_equal     '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">'
    end

    it "should transform XHTML doctypes" do
      Dang::it("!!! xhtml 1").must_equal              '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
      Dang::it("!!! xhtml 1 transitional").must_equal '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
      Dang::it("!!! xhtml 1 strict").must_equal       '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
      Dang::it("!!! xhtml 1 frameset").must_equal     '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
      Dang::it("!!! xhtml 1.1").must_equal            '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
      Dang::it("!!! xhtml 1.1 basic").must_equal      '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
      Dang::it("!!! xhtml 1.2 mobile").must_equal     '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
      Dang::it("!!! xhtml rdfa").must_equal           '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
      Dang::it("!!! xhtml 5").must_equal              '<!DOCTYPE html>'
    end
  end
end
