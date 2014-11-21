require "specs/helper"

# from
# <! [if IE] !>
# <! [endif] !>
# to
# <!--[if IE]>
# <![endif]-->

describe "conditional comments" do
  it "transforms Dang conditional comment start into HTML conditional comment start" do
    Dang.it("<! [if lt  IE 6] !>").must_equal "<!--[if lt  IE 6]>"
    Dang.it("<! [if lte IE 6] !>").must_equal "<!--[if lte IE 6]>"
    Dang.it("<! [if gt  IE 6] !>").must_equal "<!--[if gt  IE 6]>"
    Dang.it("<! [if gte IE 6] !>").must_equal "<!--[if gte IE 6]>"
    Dang.it("<! [if IE] !>").must_equal       "<!--[if IE]>"
    Dang.it("<! [if IE] !>abc").must_equal    "<!--[if IE]>abc"
    Dang.it("<! [if IE]      !>").must_equal  "<!--[if IE]>"
    Dang.it("<! [if !IE] !>").must_equal      "<!--[if !IE]>"
    Dang.it("<! [if !IE 6] !>").must_equal    "<!--[if !IE 6]>"
    Dang.it("<! [if !IE 5.5] !>").must_equal  "<!--[if !IE 5.5]>"
    Dang.it("<! [if IE 5] !>").must_equal     "<!--[if IE 5]>"
    Dang.it("<! [if IE 5.5] !>").must_equal   "<!--[if IE 5.5]>"
    Dang.it("<! [if IE 5.50] !>").must_equal  "<!--[if IE 5.50]>"
    Dang.it("<! [if IE 6] !>").must_equal     "<!--[if IE 6]>"
  end

  it "transforms Dang conditional comment closers" do
    Dang.it("<! [endif] !>").must_equal "<![endif]-->"
  end

  it "transforms Dang conditional comment closers with whitespace" do
    Dang.it("<!      [endif]    !>").must_equal "<![endif]-->"
  end

  it "transforms conditional comments with boolean operators" do
    Dang.it("<! [if (gt IE 5)&(lt IE 7)] !>").must_equal "<!--[if (gt IE 5)&(lt IE 7)]>"
    Dang.it("<! [if (IE 6)|(IE 7)] !>").must_equal "<!--[if (IE 6)|(IE 7)]>"
  end

  it "transforms Dang conditional comment closers with leading content" do
    Dang.it("xyz <! [endif] !>").must_equal "xyz <![endif]-->"
  end

  it "transforms Dang conditional comment closers with directly leading content" do
    Dang.it("xyz<! [endif] !>").must_equal "xyz<![endif]-->"
  end

  it "transforms one line Dang conditional comments" do
    Dang.it("<! [if IE] !>...<! [endif] !>").must_equal "<!--[if IE]>...<![endif]-->"
  end

  it "allows the body to dangified" do
    Dang.it("<! [if IE] !><h1 THIS IS IE h1><! [endif] !>").must_equal "<!--[if IE]><h1>THIS IS IE</h1><![endif]-->"
  end
end
