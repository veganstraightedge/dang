require "spectory/helper"

# filters
#   <:markdown
#     # This is a h1 heading
#     ## h2
#     *bold text*
#     * a
#     * of
#     * items
#   markdown:>

#   <:raw <!--[if (gt IE 9)|!(IE)]><!--> raw:><html.no-js[lang=en]<:raw <!--<![endif]--> raw:>

describe "filters" do
  it "can parse simple bodies" do
    Dang.it('<:raw food raw:>').must_equal 'food'
  end

  it "farms out to raw a filter" do
    Dang.it('<:raw <!--[if (gt IE 9)|!(IE)]><!--> <html lang="en" dir="ltr" class="no-js"> <!--<![endif]--> raw:>').must_equal '<!--[if (gt IE 9)|!(IE)]><!--> <html lang="en" dir="ltr" class="no-js"> <!--<![endif]-->'
  end

  it "farms out to 2 raw filters with DANG in between" do
    Dang.it('<:raw <!--[if (gt IE 9)|!(IE)]><!--> raw:> <html.no-js[lang=en][dir=ltr] <:raw <!--<![endif]--> raw:> html>').must_equal "<!--[if (gt IE 9)|!(IE)]><!--> <html class='no-js' lang='en' dir='ltr'><!--<![endif]--></html>"
  end
end
