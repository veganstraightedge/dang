require "helper"

describe "array classes" do
  it "joins an array of items into space separate attribute values" do
    classes = %w(snap crackle pop)
    Dang::it("<body#mitch[class={ classes }]").must_equal   "<body id='mitch' class='snap crackle pop'>"
    Dang::it("<body#mitch[class={ %w(a b c) }]").must_equal "<body id='mitch' class='a b c'>"
  end
end
