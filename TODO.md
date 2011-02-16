# Things to Think About

## HAML like shorthand for a hash of attributes
    <body#id.class.class2{ attrs }

or

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

## Misc
    <body[foo=bar]{attrs, attrs}
    <body[foo=#{bar}]{attrs, attrs}
    <body{ hidden }

## Merge Short/Long Hand Classes
    <html#foo.bar[class=snap crackle pop mitch]
    <html id="foo" class="bar snap crackle pop mitch">

## Consider Implicit Divs
    <#id Is this lame? I kinda think it is. Think on it more. #>

## HAML like conditional comments, but with // instead of /, and with closers
    //[if IE]
    //[end]

    <!--[if IE]>
    <![endif]-->
