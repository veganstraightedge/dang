require "helper"

describe "array classes" do
  it "should example an array into space separate classes" do
    # An Array of classes that is auto joined space separated
    # <body#id.class.class2.class3
    #
    # instead as
    #
    # <- classes = %w(class class2 class3) ->
    # <body#id.[= classes =]
    # <body#id.<= classes =>
    # <body#id.#{ classes }
    # <body#id[class=<= classes =>]
    # <body#id[class=#{ classes }]
    # <body#id[class={ classes }]

    # TODO think about this syntax
  end
end
