require 'helper'
require 'attribute'

describe Attribute do
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
