require "specs/helper"

describe "interpolation" do
  # it "should allow ruby interpolation in ids"
  # it "should allow ruby interpolation in classes"

  it "should interpolate in attributes" do
    Dang.it("<time[datetime=<| Time.now.year |>-<| Time.now.month |>-<| Time.now.min |>] <| Time.now |> time>").must_equal
            "<time datetime=''>#{Time.now}</time>"
  end
end
