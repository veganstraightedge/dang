require 'helper'
require 'comment'

describe Comment do
  it "transforms DANG //comment comments into html comments" do
    Dang::it(" //comment").must_equal           "<!-- comment -->"
    Dang::it("<b BOLD b> //comment").must_equal "<b>BOLD</b> <!-- comment -->"
  end

  it "ignores double slashes with no space before it" do
    Dang::it("//comment").must_equal "//comment"
    Dang::it("http://comment.com").must_equal "http://comment.com"
  end
end
