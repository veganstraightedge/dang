require "spectory/helper"

describe "embedded ruby" do
  it "farms out to Ruby for and does not return any output" do
    Dang.it("<time <- Time.now -> time>").must_equal "<time></time>"
  end

  it "farms out to Ruby for and prints the returned output" do
    t = Time.now
    Dang.it("<time <= t => time>", binding).must_equal "<time>#{t}</time>"
  end

  it "handles both printing and non-printing ruby" do
    dang = "<- 5.times do |i| -><= i =><- end ->"
    html = "01234"
    Dang.it(dang).must_equal html
  end

  it "transforms Dang, printing Ruby and non-printing Ruby" do
    dang = "<ul <- 5.times do |i| -><li <= i => li><- end -> ul>"
    html = "<ul><li>0</li><li>1</li><li>2</li><li>3</li><li>4</li></ul>"
    Dang.it(dang).must_equal html
  end

  it "handles dang inside a p" do
    t = Time.now

    dang = "<x The time is <= Time.now => x>"
    html = "<x>The time is #{t}</x>"

    Dang.it(dang, binding).must_equal html
  end
end
