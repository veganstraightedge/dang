require 'helper'

describe Dang do
  it "transforms DANG tag to HTML tag" do
    Dang::it("<b BOLD b>").must_equal "<b>BOLD</b>"
  end

  it "transforms DANG tag#id into HTML tag with an id attribute" do
    Dang::it("<div#awesome lorem and or ipsum div>").must_equal "<div id='awesome'>lorem and or ipsum</div>"
  end

  it "transforms DANG tag.class into HTML tag with a class" do
    Dang::it("<i.pants party i>").must_equal "<i class='pants'>party</i>"
  end

  it "transforms DANG tag#id.class into HTML tag with an id and a class" do
    Dang::it("<s#pants.party woo hoo s>").must_equal "<s id='pants' class='party'>woo hoo</s>"
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

  describe "comments" do
    it "transforms DANG //comment comments into html comments" do
      Dang::it(" //comment").must_equal           "<!-- comment -->"
      Dang::it("<b BOLD b> //comment").must_equal "<b>BOLD</b> <!-- comment -->"
    end

    it "ignores double slashes with no space before it" do
      Dang::it("//comment").must_equal "//comment"
      Dang::it("http://comment.com").must_equal "http://comment.com"
    end
  end

  describe "attributes" do
    it "transforms DANG tag[attr=value] into HTML tag with an attribute and value" do
      Dang::it("<time[datetime=1979-09-18] a while ago >").must_equal "<time datetime='2010-09-18'>a while ago</time>"
    end

    it "transforms data attributes" do
      Dang::it("<span[data-lon=-104.6982][data-lat=44.5889] Devil's Tower span>").must_equal "<span data-lat='44.5889' data-lon='-104.6982'>Devil's Tower</span>"
    end

    it "transforms nested data attributes" do
      Dang::it("<span[data[lon=-104.6982][lat=44.5889]] Devil's Tower span>").must_equal "<span data-lat='44.5889' data-lon='-104.6982'>Devil's Tower</span>"
    end

    it "transforms boolean attributes" do
      Dang::it("<option[selected] California option>").must_equal "<option selected>California</option>"
    end

    it "transforms attributes with whitespace in attribute values" do
      Dang::it("<a[href=/][title=Internet Homesite Webpage]  Home a>").must_equal "<a href='/' title='Internet Homesite Webpage'>Home</a>"
    end

    it "escapes text in attributes" do
      Dang::it("<textarea#user_bio[name=user[bio\]] super awesome dude, right? textarea>").must_equal "<textarea id='user_bio' name='user[bio]'>super awesome dude, right?</textarea>"
    end

    it "escapes text in attribute values" do
      Dang::it("<a[href=/user/123][title=guy man dude[and stuff\]] guy man dude's profile page a>").must_equal "<a href='/user/123' title='guy man dude[and stuff]'>guy man dude's profile page</a>"
    end

    it "allows quoted attributes" do
      Dang::it("<html[xmlns=http://www.w3.org/1999/xhtml]['xml:lang'=en][lang=en] ... html>").must_equal "<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>...</html>"
    end

    it "allows quoted attribute values" do
      Dang::it("<html[xmlns='http://www.w3.org/1999/xhtml'][xml:lang='en'][lang='en'] ... html>").must_equal "<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>...</html>"
    end
  end

  describe "doctype" do
    # based largely on HAML's doctype with a minor variation
    # http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html#doctype_

    it "transforms !!! into html doctype" do
      Dang::it("!!!").must_equal       "<!doctype html>"
      Dang::it("!!! html5").must_equal "<!doctype html>"
    end

    it "transforms HTML4 doctypes" do
      Dang::it("!!! html4").must_equal              '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
      Dang::it("!!! html4 transitional").must_equal '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
      Dang::it("!!! html4 strict").must_equal       '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
      Dang::it("!!! html4 frameset").must_equal     '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">'
    end

    it "transforms XHTML doctypes" do
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

    it "transforms xml utf8 encoding" do
      Dang::it("!!! xml iso-8859-1").must_equal "<?xml version='1.0' encoding='iso-8859-1' ?>"
    end
  end

  describe "script" do
    it "treat script tag special" do
      dang = "
<script
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-193482-20']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();
script>
"

      html = "
<script>
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-193482-20']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();
<script>
"

      Dang::it(dang).must_equal html
    end
  end

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

  describe "well formedness" do
    it "should throw a warning when a closer is missing"
    it "should throw a warning when a closer is mismatched"
  end
end
