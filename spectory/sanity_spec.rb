require "spectory/helper"

describe "sanity" do
  before do
    @sanity = true
  end

  it "should be sane" do
    @sanity.must_equal true
  end
end
