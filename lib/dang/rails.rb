class Dang
  class View
    def handles_encoding?
      true
    end

    def valid_encoding(string, encoding)
      # If a magic encoding comment was found, tag the
      # String with this encoding. This is for a case
      # where the original String was assumed to be,
      # for instance, UTF-8, but a magic comment
      # proved otherwise
      string.force_encoding(encoding) if encoding

      # If the String is valid, return the encoding we found
      return string.encoding if string.valid_encoding?

      # Otherwise, raise an exception
      raise ActionView::WrongEncodingError.new(string, string.encoding)
    end

    ENCODING_TAG = Regexp.new("\\A(<-\\s*#{ActionView::ENCODING_FLAG}\\s*->)[ \\t]*")

    def call(template)
      template_source = template.source.dup.force_encoding(Encoding::ASCII_8BIT)

      dang = template_source.gsub(ENCODING_TAG, '')
      encoding = $2

      dang.force_encoding valid_encoding(template.source.dup, encoding)

      # Always make sure we return a String in the default_internal
      dang.encode!

      parser = Dang::Parser.new(dang, true)
      unless parser.parse
        io = StringIO.new
        parser.show_error(io)
        raise io.string
      end

      parser.compile
    end
  end

  ActionView::Template.register_template_handler :dang, View.new
end
