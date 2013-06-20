# History

## 1.0.0 / 2013-06-19

### Major Enhancements

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
   * Command line interface option:`dang -e "<i super duper i>"`

3. House Keeping

   * Gemfile for development dependencies
   * Removed kpeg as a runtime dependency
   * Hoe plugins for better release management

## 0.1.0 / 2011-02-15

### 1 major enhancement

Conception!
