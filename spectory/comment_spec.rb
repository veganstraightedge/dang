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
    Dang.it("<html markups html> <! html !>").must_equal "<html>markups</html> <!-- html -->"
  end

  it "transforms <! comments! !> with !s in them into html comments" do
    Dang.it("<b bold text b> <! b! !>").must_equal "<b>bold text</b> <!-- b! -->"
  end
end
