require "specs/helper"

describe "interpolation" do
  # it "should allow ruby interpolation in ids"
  # it "should allow ruby interpolation in classes"

  it "should interpolate in attributes" do
    foo = "bar"

    Dang.it("<time[name=<| foo |>-<| foo |>] <| foo |> time>", binding).must_equal "<time name='bar-bar'>bar</time>"
  end
end
