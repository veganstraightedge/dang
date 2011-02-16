# Things to Think About:

## HAML like shorthand for a hash of attributes
- <body#id.class.class2{attrs}
- or
- <body#id.class.class2<= attrs =>

## Ruby interpolation in ids, class, attrs, values

## An Array of classes that is auto joined space separated
- <body#id.class.class2.class3
- instead as
- <- classes = %w(class class2 class3) ->
- <body#id.[= classes =]
- or
- <body#id.<= classes =>
- or
- <body#id.#{ classes }
- I dunno, but maybe only like
- <body#id[class=<= classes =>]
- or
- <body#id[class=#{ classes }]
