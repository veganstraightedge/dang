require "spectory/helper"

describe "comments" do
  it "transforms DANG <! comment !> comments into html comments" do
    Dang.it("<! comment !>").must_equal "<!-- comment -->"
  end

  it "transforms multiline DANG <! comment !> comments into multiline html comments" do
    Dang.it("<!
    comment
    !>").must_equal "<!--
    comment
    -->"
  end

  it "transforms trailing <! comments !> into html comments" do
    Dang.it("<html html html> <! html !>").must_equal "<html>html</html> <!-- html -->"
  end
end
