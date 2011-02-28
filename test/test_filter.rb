require "helper"
require "filter"
require "markdown"

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

describe Filter do
  describe Markdown do
    it "farms out to markdown processing with markdown filter" do
      Dang::it("<:markdown # heading markdown:>").must_equal "<h1>heading</h1>"
    end
  end
end
