require "spec/helper"

# <! [if IE] !>
# <! [end] !>
#
# <!--[if IE]>
# <![endif]-->

describe "conditional comments" do
#   it "transforms IE conditional comments" do
#     Dang.it("<! [if IE] !>\n...\n<! [end] !>").must_equal "<!--[if IE]>\n...\n<![endif]-->"
#   end
# 
#   it "transforms IE6 conditional comments" do
#     Dang.it("<! [if IE6] !>\n...\n<! [end] !>").must_equal "<!--[if IEe]>\n...\n<![endif]-->"
#   end
# 
#   it "does all the permutations of IE conditional comments"
#   it "transforms IE conditional comments for non IE"

  # it "transforms one line conditional comments" do
  #   Dang.it("<! [if IE] !>...<! [end] !>").must_equal "<!--[if IE]>...<![endif]-->"
  # end

  it "transforms DANG conditional comment start into HTML conditional comment start" do
    Dang.it("<! [if IE] !>").must_equal "<!--[if IE]>"
  end

  it "transforms DANG conditional comment closers into HTML conditional comment closers" do
    Dang.it("<! [end] !>").must_equal "<![endif]-->"
  end
end
