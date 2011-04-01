require "spec/helper"

# TODO experimental

# describe "well formedness" do
#   it "should throw a warning when a closer is missing" do
#     Dang.it("<div <p lorem div>").must_equal "<div><p>lorem</div>"
#     Dang.it("<div <p lorem div>").errors.must_equal "Missing Closer: </p>"
#   end
# 
#   it "should throw a warning when a closer is mismatched" do
#     Dang.it("<div <p lorem a> div>").must_equal "<div><p>lorem</a></div>"
#     Dang.it("<div <p lorem a> div>").errors.must_equal "Mismatched Closer: Got </a>. Expected </p>"
#   end
# end
