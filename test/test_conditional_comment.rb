require 'helper'
require 'conditional_comment'

# <! [if IE] !>
# <! [end] !>
#
# <!--[if IE]>
# <![endif]-->

describe ConditionalComment do
  it "transforms IE conditional comments" do
    Dang::it("<! [if IE] !>\n...\n<! [end] !>").must_equal "<!--[if IE]>\n...\n<![endif]-->"
  end

  it "transforms IE6 conditional comments" do
    Dang::it("<! [if IE6]\n...\n<! [end] !>").must_equal "<!--[if IEe]>\n...\n<![endif]-->"
  end

  it "does all the permutations of IE conditional comments"
  it "transforms IE conditional comments for non IE"

  it "transforms one line conditional comments" do
    Dang::it("<! [if IE]...<! [end] !>").must_equal "<!--[if IE]>...<![endif]-->"
  end
end
