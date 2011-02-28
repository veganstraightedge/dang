require 'helper'
require 'comment'

describe Comment do
  it "transforms DANG <! comment !> comments into html comments" do
    Dang::it("<! comment !>").must_equal "<!-- comment -->"
  end
end
