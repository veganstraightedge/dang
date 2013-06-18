require "spectory/helper"

describe "files" do
  it "can transform a whole document" do
    Dang.it( File.open("files/iamshane-com.html.dang") ).must_equal File.open("files/iamshane-com.html")
  end
end
