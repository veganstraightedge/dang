## HAML like shorthand for a hash of attributes
Ideas

    <body[foo=bar]{attrs, attrs}
    <body[foo=#{bar}]{attrs, attrs}
    <body{ hidden }
    <body#id.class.class2{ attrs }
    <body#id.class.class2<= attrs =>

## Ruby interpolation in ids, class, attrs, values

## An Array of classes that is auto joined space separated
    <body#id.class.class2.class3

instead as

    <- classes = %w(class class2 class3) ->
    <body#id.[= classes =]

or

    <body#id.<= classes =>

or

    <body#id.#{ classes }

I dunno, but maybe only like

    <body#id[class=<= classes =>]

or

    <body#id[class=#{ classes }]

## Merge Short/Long Hand Classes
    <html#foo.bar[class=snap crackle pop mitch]
    <html id="foo" class="bar snap crackle pop mitch">

