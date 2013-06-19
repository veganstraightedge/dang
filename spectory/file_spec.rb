require "spectory/helper"

describe "files" do
  it "can transform a whole document" do
    dang_path = File.expand_path("../files/iamshane-com.html.dang", __FILE__)
    html_path = File.expand_path("../files/iamshane-com.html",      __FILE__)

    dang = File.open(dang_path, "rb").read
    html = File.open(html_path, "rb").read

    Dang.it(dang).must_equal html
  end
end
