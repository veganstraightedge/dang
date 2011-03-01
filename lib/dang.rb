class Dang
  VERSION = '0.1.0'

  class << self
    def it(str)
      parser = Dang::Parser.new(str)
      unless parser.parse
        parser.show_error
        raise "parse error"
      end

      parser.output
    end
  end

end

require 'parser'
