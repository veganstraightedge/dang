require "helper"
require "hash_attribute"

describe HashAttribute do
  it "should have a shorthand for a hash as attributes" do
    # HAML like shorthand for a hash of attributes
    # Ideas

    # <body[foo=bar]{attrs, attrs}
    # <body[foo=#{bar}]{attrs, attrs}
    # <body{ hidden }
    # <body#id.class.class2{ attrs }
    # <body#id.class.class2<= attrs =>

    # TODO think about this syntax    
  end
end