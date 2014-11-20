# History

## 2.0.0 / 2014-11-20

### Major Features

1. Fixed two major and obvious syntax mistakes.

   `<- non-printing ruby ->` : As a syntax works great in a vaccum,
   but not in Ruby 1.9 or higher because of the `->` stabby proc.
   Duh. That's our bad. Sorry that we didn't catch it in our design
   and testing.

   `<= printing ruby =>` : Same goes for this. `=>` is used in hashes.
   Double duh. Both of these should've never made it into the spec.

   For 2.0, we've changed both of them to similar but different syntaxes.

   * `<- non-printing ruby ->` becomes  `<: non-printing ruby :>`
   * `<= printing ruby =>`     becomes  `<| printing ruby |>`

   Our reason for using `<: :>` is because we were already using a similar
   syntax for `filters`. `<:raw raw:>`, `<:markdown markdown:>`, etc.
   Following this pattern, `<: :>` is the default filter and therefore
   an alias/shorthand for `<:ruby ruby:>`.

   `<| |>` was chosen for visual symmetry/balance and because pipes are
   already used in Ruby, so they won't feel out of place in Ruby/Rals views.
   We didn't want to introduce **another** symbol to the aesthic of views.


## 1.0.0 / 2013-09-18

### Major Features

1. Dang to html transformation

   * **Syntax**: `<tag content tag>`
   * **Syntax**: `<tag#id content tag>`
   * **Syntax**: `<tag#class content tag>`
   * **Syntax**: `<tag[attr=value] content tag>`
   * **Syntax**: `<! html comment !>`
   * **Syntax**: Embedded non-printing ruby (<- if logged_in? ->)
   * **Syntax**: Embedded printing ruby (<= @user.name =>)
   * **Syntax**: `!!!` doctype shorthand inspired by HAML

2. Command Line Interface

   * `dang path/to/file.html.dang`
   * Option: `dang -e "<i super duper i>"`

3. House Keeping

   * Gemfile for development dependencies
   * Removed kpeg as a runtime dependency
   * Hoe plugins for better release management

## 0.1.0 / 2011-02-15

### 1 major enhancement

Conception!
