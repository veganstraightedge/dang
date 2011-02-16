require 'helper'

# HAML like conditional comments, but with // instead of /, and with closers
# //[if IE]
# //[end]
#
# <!--[if IE]>
# <![endif]-->

describe "conditional comments" do
  it "//[if IE]...[end]"
  it "//[if lte IE6]...[end]"
end