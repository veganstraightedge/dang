require 'stringio'

require 'rubygems'
require 'kpeg'

require 'dang/parser'

class Dang
  VERSION = '1.0.0.rc'

  @filters = {}

  class << self
    def it(str, env=nil)
      parser = Dang::Parser.new(str, true)
      unless parser.parse
        io = StringIO.new
        parser.show_error(io)
        raise io.string
      end

      parser.output(env)
    end

    def register_filter(name, filter)
      @filters[name] = filter
    end

    def run_filter(name, text)
      if filter = @filters[name]
        return filter[text]
      else
        raise "Unknown filter: \"#{name}\""
      end
    end
  end

  # A default filter.
  register_filter "raw", proc { |str| str }
end
