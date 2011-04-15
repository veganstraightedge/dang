require "spectory/helper"

describe "embedded ruby" do
  it "farms out to Ruby for and does not return any output" do
    Dang.it("<time><- Time.now -></time>").must_equal "<time></time>"
  end

  it "farms out to Ruby for and prints the returned output" do
    Dang.it("<time><= Time.now =></time>").must_equal "<time>#{Time.now}</time>"
  end

  it "handles both printing and non-printing ruby" do
    dang = "<- 5.times do |i| -><= i =><- end ->"
    html = "01234"
    Dang.it(dang).must_equal html
  end

  it "transforms DANG, printing Ruby and non-printing Ruby" do
    dang = "<ul <- 5.times do |i| -><li <= i => to show non/printing ruby li><- end -> ul>"
    html = "<ul><li>0</li><li>1</li><li>2</li><li>3</li><li>4</li></ul>"
    Dang.it(dang).must_equal html
  end
end
