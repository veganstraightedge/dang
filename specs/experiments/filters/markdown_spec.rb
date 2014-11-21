require "specs/helper"

# filters
#   <:markdown
#     # This is an h1 heading
#     ## h2
#     *bold text*
#     * a
#     * of
#     * items
#   markdown:>

# describe "filters" do
#   it "farms out to raw a markdown filter" do
#     Dang.it("<:markdown # an h1 markdown:>").must_equal "<h1>an h1</h1>")
#   end
# 
#   it "farms out to 2 markdown filters with Dang in between" do
#     Dang.it("<:markdown # h1 markdown:> <h2 this is<:markdown **bold text** markdown:> inside an h2>".must_equal "<h1>h1</h1> <h2>this is <b>bold text</b> inside an h2</h2>")
#   end
# end
