require 'helper'

class TestSyntax < DangIt::TestCase
  describe "sanity" do  
    it "should be sane" do
      true.must_equal true
    end
  end
end
