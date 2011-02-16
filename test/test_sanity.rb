require 'helper'

class TestSyntax < Dangx::TestCase
  describe "sanity" do  
    it "should be sane" do
      true.must_equal true
    end
  end
end
