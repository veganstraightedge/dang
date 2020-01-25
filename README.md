# Dang

https://github.com/veganstraightedge/dang

## Description

Dang is a Ruby templating language.
It uses angle brackets and CSS syntax.
Somewhere between ERB and Haml.


## Build Status

[![Build Status](https://travis-ci.org/veganstraightedge/dang.png?branch=master)](https://travis-ci.org/veganstraightedge/dang)


## Features

* CSS selectors for HTML tags + attributes
* Not as noisy syntax than ERB
* Not quite as elegant as [Haml](http://haml.info)
* No %s in your code
* More closers than Haml
* A lot is based on / inspired by [Haml](http://haml.info)


## Synopsis
### Syntax

* `<b a simple bold tag b>`
* `<div#id div with an id div>`
* `<p.class lorem ipsum p>`
* `<a[href=/] Home a>`
* `<! html comment !>`
* `<: non_printing(ruby) :>`
* `<| printing(ruby) |>`
* `!!!` doctype shorthand inspired by HAML


## Usage

From the command line, transform a file of dang into html:

`dang path/to/file.html.dang`

Or just a snippet of dang into html:

`dang -e "<i snippet i>"`


## Current Version

2.1.0


## Requirements

For development:

* [rake](https://github.com/jimweirich/rake)
* [kpeg](https://github.com/evanphx/kpeg)
* [hoe](https://github.com/seattlerb/hoe)
* [minitest](https://github.com/seattlerb/minitest)


## Installation

### Gemfile

Add this line to your application's Gemfile:

```ruby
gem 'dang'
```

### Manual

Or install it yourself as:

```bash
gem install dang
```

You may need to use `sudo` to install it manually.


## Developers

After checking out the source, run:

```bash
bundle
```

This will install any missing dependencies.


## Authors

* Shane Becker / [@veganstraightedge](https://github.com/veganstraightedge)
* Evan Phoenix / [@evanphx](https://github.com/evanphx)


## Contributing

1. Fork it
2. Get it running
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Write your code and **specs**
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request

If you find bugs, have feature requests or questions, please
[file an issue](https://github.com/veganstraightedge/dang).


## License

**PUBLIC DOMAIN**

Your heart is as free as the air you breathe. <br>
The ground you stand on is liberated territory.

In legal text, Dang is dedicated to the public domain
using Creative Commons -- CC0 1.0 Universal.

[http://creativecommons.org/publicdomain/zero/1.0](http://creativecommons.org/publicdomain/zero/1.0 "Creative Commons &mdash; CC0 1.0 Universal")
