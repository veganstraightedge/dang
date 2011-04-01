require "spec/helper"

# from
# <! [if IE] !>
# <! [end] !>
# to
# <!--[if IE]>
# <![endif]-->

describe "conditional comments" do
  it "transforms DANG conditional comment start into HTML conditional comment start" do
    Dang.it("<! [if IE] !>").must_equal      "<!--[if IE]>"
    Dang.it("<! [if IE] !>abc").must_equal   "<!--[if IE]>abc"
    Dang.it("<! [if IE]      !>").must_equal "<!--[if IE]>"
  end

  it "transforms DANG conditional comment closers into HTML conditional comment closers" do
    Dang.it("<! [end] !>").must_equal         "<![endif]-->"
    Dang.it("<!      [end]    !>").must_equal "<![endif]-->"
    Dang.it("xyz<! [end] !>").must_equal      "xyz<![endif]-->"
  end

  it "transforms one line DANG conditional comments into one line HTML conditional comments" do
    Dang.it("<! [if IE] !>...<! [end] !>").must_equal "<!--[if IE]>...<![endif]-->"
  end

  it "transforms conditional comments to a particular IE version" do
    Dang.it("<! [if IE5] !>...<! [end] !>").must_equal "<!--[if IE5]>...<![endif]-->"
    Dang.it("<! [if IE6] !>...<! [end] !>").must_equal "<!--[if IE6]>...<![endif]-->"
    Dang.it("<! [if IE7] !>...<! [end] !>").must_equal "<!--[if IE7]>...<![endif]-->"
    Dang.it("<! [if IE8] !>...<! [end] !>").must_equal "<!--[if IE8]>...<![endif]-->"
    Dang.it("<! [if IE9] !>...<! [end] !>").must_equal "<!--[if IE9]>...<![endif]-->"
  end

  # it "does all the permutations of IE conditional comments"
  # it "transforms IE conditional comments for non IE"
end
