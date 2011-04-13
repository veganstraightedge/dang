require "spectory/helper"

describe "data attributes" do
  it "transforms normal data attributes comments" do
    Dang.it("<span[data-foo=party][data-bar=time] now span>").must_equal "<span data-foo='party' data-bar='time'>now</span>"
  end

  it "transforms nested data attributes comments" do
    Dang.it("<span[data[foo=party][bar=time]] now span>").must_equal "<span data-foo='party' data-bar='time'>now</span>"
  end
end
