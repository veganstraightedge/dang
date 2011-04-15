require "spectory/helper"

# Think about filters
#   <:markdown
#   	# This is a h1 heading
#   	## h2
#   	*bold text*
#   	* a
#   	* of
#   	* items
#   markdown:>

# TODO experimental

# describe "filters" do
#   describe "markdown" do
#     it "farms out to markdown processing with markdown filter" do
#       Dang.it("<:markdown # heading markdown:>").must_equal "<h1>heading</h1>"
#     end
#   end
# end


describe "filters" do
  it "can parse simple bodies" do
    Dang.it('<:raw food raw:>').must_equal 'food'
  end

  it "farms out to a filter" do
    Dang.it('<:raw <!--[if (gt IE 9)|!(IE)]><!--> <html lang="en" dir="ltr" class="no-js"> <!--<![endif]--> raw:>').must_equal '<!--[if (gt IE 9)|!(IE)]><!--> <html lang="en" dir="ltr" class="no-js"> <!--<![endif]-->'
  end
end
