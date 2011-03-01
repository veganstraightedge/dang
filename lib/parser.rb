class Dang::Parser
# STANDALONE START
    def setup_parser(str, debug=false)
      @string = str
      @pos = 0
      @memoizations = Hash.new { |h,k| h[k] = {} }
      @result = nil
      @text = nil
      @failing_offset = -1
      @expected_string = []

      enhance_errors! if debug
    end

    # This is distinct from setup_parser so that a standalone parser
    # can redefine #initialize and still have access to the proper
    # parser setup code.
    #
    def initialize(str, debug=false)
      setup_parser(str, debug)
    end

    attr_reader :string
    attr_reader :result, :text, :failing_offset, :expected_string
    attr_accessor :pos

    # STANDALONE START
    def current_column(target=pos)
      offset = 0
      string.each_line do |line|
        len = line.size
        return (target - offset) if offset + len >= target
        offset += len
      end

      -1
    end

    def current_line(target=pos)
      cur_offset = 0
      cur_line = 0

      string.each_line do |line|
        cur_line += 1
        cur_offset += line.size
        return cur_line if cur_offset >= target
      end

      -1
    end

    def lines
      lines = []
      string.each_line { |l| lines << l }
      lines
    end

    def error_expectation
      error_pos = failing_offset()
      line_no = current_line(error_pos)
      col_no = current_column(error_pos)

      expected = expected_string()

      prefix = nil

      case expected
      when String
        prefix = expected.inspect
      when Range
        prefix = "to be between #{expected.begin} and #{expected.end}"
      when Array
        prefix = "to be one of #{expected.inspect}"
      when nil
        prefix = "anything (no more input)"
      else
        prefix = "unknown"
      end

      return "Expected #{prefix} at line #{line_no}, column #{col_no} (offset #{error_pos})"
    end

    def show_error(io=STDOUT)
      error_pos = failing_offset()
      line_no = current_line(error_pos)
      col_no = current_column(error_pos)

      io.puts error_expectation()
      io.puts "Got: #{string[error_pos,1].inspect}"
      line = lines[line_no-1]
      io.puts "=> #{line}"
      io.print(" " * (col_no + 3))
      io.puts "^"
    end

    #

    def set_text(start)
      @text = @string[start..@pos-1]
    end

    def show_pos
      width = 10
      if @pos < width
        "#{@pos} (\"#{@string[0,@pos]}\" @ \"#{@string[@pos,width]}\")"
      else
        "#{@pos} (\"... #{@string[@pos - width, width]}\" @ \"#{@string[@pos,width]}\")"
      end
    end

    def add_failure(obj)
      @expected_string = obj
      @failing_offset = @pos if @pos > @failing_offset
    end

    def match_string(str)
      len = str.size
      if @string[pos,len] == str
        @pos += len
        return str
      end

      add_failure(str)

      return nil
    end

    def fail_range(start,fin)
      @pos -= 1

      add_failure Range.new(start, fin)
    end

    def scan(reg)
      if m = reg.match(@string[@pos..-1])
        width = m.end(0)
        @pos += width
        return true
      end

      add_failure reg

      return nil
    end

    def get_byte
      if @pos >= @string.size
        add_failure nil
        return nil
      end

      s = @string[@pos]
      @pos += 1
      s
    end

    module EnhancedErrors
      def add_failure(obj)
        @expected_string << obj
        @failing_offset = @pos if @pos > @failing_offset
      end

      def match_string(str)
        if ans = super
          @expected_string.clear
        end

        ans
      end

      def scan(reg)
        if ans = super
          @expected_string.clear
        end

        ans
      end

      def get_byte
        if ans = super
          @expected_string.clear
        end

        ans
      end
    end

    def enhance_errors!
      extend EnhancedErrors
    end

    def parse
      _root ? true : false
    end

    class LeftRecursive
      def initialize(detected=false)
        @detected = detected
      end

      attr_accessor :detected
    end

    class MemoEntry
      def initialize(ans, pos)
        @ans = ans
        @pos = pos
        @uses = 1
        @result = nil
      end

      attr_reader :ans, :pos, :uses, :result

      def inc!
        @uses += 1
      end

      def move!(ans, pos, result)
        @ans = ans
        @pos = pos
        @result = result
      end
    end

    def find_memo(rule)
      @memoizations[rule][@pos]
    end

    def create_memo(rule)
      lr = LeftRecursive.new(false)
      m = MemoEntry.new(lr, @pos)
      @memoizations[rule][@pos] = m
      return m
    end

    def apply(rule, method_name)
      if m = @memoizations[rule][@pos]
        m.inc!

        prev = @pos
        @pos = m.pos
        if m.ans.kind_of? LeftRecursive
          m.ans.detected = true
          return nil
        end

        @result = m.result

        return m.ans
      else
        lr = LeftRecursive.new(false)
        m = MemoEntry.new(lr, @pos)
        @memoizations[rule][@pos] = m
        start_pos = @pos

        ans = __send__ method_name

        m.move! ans, @pos, @result

        # Don't bother trying to grow the left recursion
        # if it's failing straight away (thus there is no seed)
        if ans and lr.detected
          return grow_lr(rule, method_name, start_pos, m)
        else
          return ans
        end

        return ans
      end
    end

    def grow_lr(rule, method_name, start_pos, m)
      while true
        @pos = start_pos
        @result = m.result

        ans = __send__ method_name
        return nil unless ans

        break if @pos <= m.pos

        m.move! ans, @pos, @result
      end

      @result = m.result
      @pos = m.pos
      return m.ans
    end

    #


  def initialize(str, debug=false)
    setup_parser(str, debug)
    @doctype = "html"
  end

  DOC_TYPES = {
    "html" => "<!doctype html>",
    "html5" => "<!doctype html>",
    "html4" => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">',
    "html4 transitional" => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">',
    "html4 strict" => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">',
    "html4 frameset" => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">',

    "xhtml 1" => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
    "xhtml 1 transitional" => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
    "xhtml 1 strict" => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
    "xhtml 1 frameset" => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">',
    "xhtml 1.1" => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
    "xhtml 1.1 basic" => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">',
    "xhtml 1.2 mobile" => '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">',
    "xhtml rdfa" =>  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">',
    "xhtml 5" => '<!DOCTYPE html>',

    "xml iso-8859-1" => "<?xml version='1.0' encoding='iso-8859-1' ?>"
  }

  def html_doctype
    unless DOC_TYPES.key? @doctype
      warn "doctype '#{@doctype}' not understood, using 'html'"
      @doctype = "html"
    end

    DOC_TYPES[@doctype]
  end

  def output
    html_doctype
  end



  # space = (" " | "\t")
  def _space

    _save = self.pos
    while true # choice
    _tmp = match_string(" ")
    break if _tmp
    self.pos = _save
    _tmp = match_string("\t")
    break if _tmp
    self.pos = _save
    break
    end # end choice

    return _tmp
  end

  # - = space*
  def __hyphen_
    while true
    _tmp = apply('space', :_space)
    break unless _tmp
    end
    _tmp = true
    return _tmp
  end

  # eol = "\n"
  def _eol
    _tmp = match_string("\n")
    return _tmp
  end

  # eof = !.
  def _eof
    _save = self.pos
    _tmp = get_byte
    self.pos = _save
    _tmp = _tmp ? nil : true
    return _tmp
  end

  # rest = < (!eol .)* > (eol | eof) { text }
  def _rest

    _save = self.pos
    while true # sequence
    _text_start = self.pos
    while true

    _save2 = self.pos
    while true # sequence
    _save3 = self.pos
    _tmp = apply('eol', :_eol)
    self.pos = _save3
    _tmp = _tmp ? nil : true
    unless _tmp
      self.pos = _save2
      break
    end
    _tmp = get_byte
    unless _tmp
      self.pos = _save2
    end
    break
    end # end sequence

    break unless _tmp
    end
    _tmp = true
    if _tmp
      set_text(_text_start)
    end
    unless _tmp
      self.pos = _save
      break
    end

    _save4 = self.pos
    while true # choice
    _tmp = apply('eol', :_eol)
    break if _tmp
    self.pos = _save4
    _tmp = apply('eof', :_eof)
    break if _tmp
    self.pos = _save4
    break
    end # end choice

    unless _tmp
      self.pos = _save
      break
    end
    @result = begin;  text ; end
    _tmp = true
    unless _tmp
      self.pos = _save
    end
    break
    end # end sequence

    return _tmp
  end

  # doctype = "!!!" - rest:r { @doctype = r.empty? ? "html" : r }
  def _doctype

    _save = self.pos
    while true # sequence
    _tmp = match_string("!!!")
    unless _tmp
      self.pos = _save
      break
    end
    _tmp = apply('-', :__hyphen_)
    unless _tmp
      self.pos = _save
      break
    end
    _tmp = apply('rest', :_rest)
    r = @result
    unless _tmp
      self.pos = _save
      break
    end
    @result = begin;  @doctype = r.empty? ? "html" : r ; end
    _tmp = true
    unless _tmp
      self.pos = _save
    end
    break
    end # end sequence

    return _tmp
  end

  # root = doctype
  def _root
    _tmp = apply('doctype', :_doctype)
    return _tmp
  end
end
