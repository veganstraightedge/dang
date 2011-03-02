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

 #%%
  def initialize(str, debug=false)
    setup_parser(str, debug)
    @doctype = nil
    @output = ""
  end

  DOC_TYPES = {
    "html"                 => "<!doctype html>",
    "html5"                => "<!doctype html>",
    "html4"                => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">',
    "html4 transitional"   => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">',
    "html4 strict"         => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">',
    "html4 frameset"       => '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">',

    "xhtml 1"              => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
    "xhtml 1 transitional" => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
    "xhtml 1 strict"       => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
    "xhtml 1 frameset"     => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">',
    "xhtml 1.1"            => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
    "xhtml 1.1 basic"      => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">',
    "xhtml 1.2 mobile"     => '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">',
    "xhtml rdfa"           => '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">',
    "xhtml 5"              => '<!DOCTYPE html>',

    "xml iso-8859-1"       => "<?xml version='1.0' encoding='iso-8859-1' ?>"
  }

  def html_doctype
    return "" unless @doctype

    unless DOC_TYPES.key? @doctype
      warn "doctype '#{@doctype}' not understood, using 'html'"
      @doctype = "html"
    end

    DOC_TYPES[@doctype].dup
  end

  def output
    str = html_doctype
    out = @output.strip

    unless out.empty?
      str << "\n" << out
    end

    str
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

  # bs = (" " | "\t" | "\n")
  def _bs

    _save = self.pos
    while true # choice
    _tmp = match_string(" ")
    break if _tmp
    self.pos = _save
    _tmp = match_string("\t")
    break if _tmp
    self.pos = _save
    _tmp = match_string("\n")
    break if _tmp
    self.pos = _save
    break
    end # end choice

    return _tmp
  end

  # - = bs+
  def __hyphen_
    _save = self.pos
    _tmp = apply('bs', :_bs)
    if _tmp
      while true
        _tmp = apply('bs', :_bs)
        break unless _tmp
      end
      _tmp = true
    else
      self.pos = _save
    end
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

  # doctype = "!!!" space* rest:r { @doctype = r.empty? ? "html" : r }
  def _doctype

    _save = self.pos
    while true # sequence
    _tmp = match_string("!!!")
    unless _tmp
      self.pos = _save
      break
    end
    while true
    _tmp = apply('space', :_space)
    break unless _tmp
    end
    _tmp = true
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

  # name = < /[a-zA-Z0-9_-]+/ > { text }
  def _name

    _save = self.pos
    while true # sequence
    _text_start = self.pos
    _tmp = scan(/\A(?-mix:[a-zA-Z0-9_-]+)/)
    if _tmp
      set_text(_text_start)
    end
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

  # start = "<" name:n { n }
  def _start

    _save = self.pos
    while true # sequence
    _tmp = match_string("<")
    unless _tmp
      self.pos = _save
      break
    end
    _tmp = apply('name', :_name)
    n = @result
    unless _tmp
      self.pos = _save
      break
    end
    @result = begin;  n ; end
    _tmp = true
    unless _tmp
      self.pos = _save
    end
    break
    end # end sequence

    return _tmp
  end

  # pts = (space+ { "" } | < eol bs* > { text })
  def _pts

    _save = self.pos
    while true # choice

    _save1 = self.pos
    while true # sequence
    _save2 = self.pos
    _tmp = apply('space', :_space)
    if _tmp
      while true
        _tmp = apply('space', :_space)
        break unless _tmp
      end
      _tmp = true
    else
      self.pos = _save2
    end
    unless _tmp
      self.pos = _save1
      break
    end
    @result = begin;  "" ; end
    _tmp = true
    unless _tmp
      self.pos = _save1
    end
    break
    end # end sequence

    break if _tmp
    self.pos = _save

    _save3 = self.pos
    while true # sequence
    _text_start = self.pos

    _save4 = self.pos
    while true # sequence
    _tmp = apply('eol', :_eol)
    unless _tmp
      self.pos = _save4
      break
    end
    while true
    _tmp = apply('bs', :_bs)
    break unless _tmp
    end
    _tmp = true
    unless _tmp
      self.pos = _save4
    end
    break
    end # end sequence

    if _tmp
      set_text(_text_start)
    end
    unless _tmp
      self.pos = _save3
      break
    end
    @result = begin;  text ; end
    _tmp = true
    unless _tmp
      self.pos = _save3
    end
    break
    end # end sequence

    break if _tmp
    self.pos = _save
    break
    end # end choice

    return _tmp
  end

  # end = name:n ">" { n }
  def _end

    _save = self.pos
    while true # sequence
    _tmp = apply('name', :_name)
    n = @result
    unless _tmp
      self.pos = _save
      break
    end
    _tmp = match_string(">")
    unless _tmp
      self.pos = _save
      break
    end
    @result = begin;  n ; end
    _tmp = true
    unless _tmp
      self.pos = _save
    end
    break
    end # end sequence

    return _tmp
  end

  # slash = - "/>"
  def _slash

    _save = self.pos
    while true # sequence
    _tmp = apply('-', :__hyphen_)
    unless _tmp
      self.pos = _save
      break
    end
    _tmp = match_string("/>")
    unless _tmp
      self.pos = _save
    end
    break
    end # end sequence

    return _tmp
  end

  # marker = (start | - end)
  def _marker

    _save = self.pos
    while true # choice
    _tmp = apply('start', :_start)
    break if _tmp
    self.pos = _save

    _save1 = self.pos
    while true # sequence
    _tmp = apply('-', :__hyphen_)
    unless _tmp
      self.pos = _save1
      break
    end
    _tmp = apply('end', :_end)
    unless _tmp
      self.pos = _save1
    end
    break
    end # end sequence

    break if _tmp
    self.pos = _save
    break
    end # end choice

    return _tmp
  end

  # chunk = < (!marker .)* > { text }
  def _chunk

    _save = self.pos
    while true # sequence
    _text_start = self.pos
    while true

    _save2 = self.pos
    while true # sequence
    _save3 = self.pos
    _tmp = apply('marker', :_marker)
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
    @result = begin;  text ; end
    _tmp = true
    unless _tmp
      self.pos = _save
    end
    break
    end # end sequence

    return _tmp
  end

  # part = (tag | chunk)
  def _part

    _save = self.pos
    while true # choice
    _tmp = apply('tag', :_tag)
    break if _tmp
    self.pos = _save
    _tmp = apply('chunk', :_chunk)
    break if _tmp
    self.pos = _save
    break
    end # end choice

    return _tmp
  end

  # body = (part:p body:b { "#{p}#{b}" } | part)
  def _body

    _save = self.pos
    while true # choice

    _save1 = self.pos
    while true # sequence
    _tmp = apply('part', :_part)
    p = @result
    unless _tmp
      self.pos = _save1
      break
    end
    _tmp = apply('body', :_body)
    b = @result
    unless _tmp
      self.pos = _save1
      break
    end
    @result = begin;  "#{p}#{b}" ; end
    _tmp = true
    unless _tmp
      self.pos = _save1
    end
    break
    end # end sequence

    break if _tmp
    self.pos = _save
    _tmp = apply('part', :_part)
    break if _tmp
    self.pos = _save
    break
    end # end choice

    return _tmp
  end

  # key = name
  def _key
    _tmp = apply('name', :_name)
    return _tmp
  end

  # val = < (!"]" .)* > { text }
  def _val

    _save = self.pos
    while true # sequence
    _text_start = self.pos
    while true

    _save2 = self.pos
    while true # sequence
    _save3 = self.pos
    _tmp = match_string("]")
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
    @result = begin;  text ; end
    _tmp = true
    unless _tmp
      self.pos = _save
    end
    break
    end # end sequence

    return _tmp
  end

  # attr = "[" key:k "=" val:v "]" { "#{k}='#{v}'" }
  def _attr

    _save = self.pos
    while true # sequence
    _tmp = match_string("[")
    unless _tmp
      self.pos = _save
      break
    end
    _tmp = apply('key', :_key)
    k = @result
    unless _tmp
      self.pos = _save
      break
    end
    _tmp = match_string("=")
    unless _tmp
      self.pos = _save
      break
    end
    _tmp = apply('val', :_val)
    v = @result
    unless _tmp
      self.pos = _save
      break
    end
    _tmp = match_string("]")
    unless _tmp
      self.pos = _save
      break
    end
    @result = begin;  "#{k}='#{v}'" ; end
    _tmp = true
    unless _tmp
      self.pos = _save
    end
    break
    end # end sequence

    return _tmp
  end

  # attrs = (attr:a attrs:l { "#{a} #{l}" } | attr)
  def _attrs

    _save = self.pos
    while true # choice

    _save1 = self.pos
    while true # sequence
    _tmp = apply('attr', :_attr)
    a = @result
    unless _tmp
      self.pos = _save1
      break
    end
    _tmp = apply('attrs', :_attrs)
    l = @result
    unless _tmp
      self.pos = _save1
      break
    end
    @result = begin;  "#{a} #{l}" ; end
    _tmp = true
    unless _tmp
      self.pos = _save1
    end
    break
    end # end sequence

    break if _tmp
    self.pos = _save
    _tmp = apply('attr', :_attr)
    break if _tmp
    self.pos = _save
    break
    end # end choice

    return _tmp
  end

  # tag = (start:l slash { "<#{l} />" } | start:l attrs:a slash { "<#{l} #{a} />" } | start:l attrs:a pts body:b pts:es end:r { "<#{l} #{a}>#{b}#{es}</#{r}>" } | start:l pts:s body:b pts:es end:r { "<#{l}>#{s}#{b}#{es}</#{r}>" })
  def _tag

    _save = self.pos
    while true # choice

    _save1 = self.pos
    while true # sequence
    _tmp = apply('start', :_start)
    l = @result
    unless _tmp
      self.pos = _save1
      break
    end
    _tmp = apply('slash', :_slash)
    unless _tmp
      self.pos = _save1
      break
    end
    @result = begin;  "<#{l} />" ; end
    _tmp = true
    unless _tmp
      self.pos = _save1
    end
    break
    end # end sequence

    break if _tmp
    self.pos = _save

    _save2 = self.pos
    while true # sequence
    _tmp = apply('start', :_start)
    l = @result
    unless _tmp
      self.pos = _save2
      break
    end
    _tmp = apply('attrs', :_attrs)
    a = @result
    unless _tmp
      self.pos = _save2
      break
    end
    _tmp = apply('slash', :_slash)
    unless _tmp
      self.pos = _save2
      break
    end
    @result = begin;  "<#{l} #{a} />" ; end
    _tmp = true
    unless _tmp
      self.pos = _save2
    end
    break
    end # end sequence

    break if _tmp
    self.pos = _save

    _save3 = self.pos
    while true # sequence
    _tmp = apply('start', :_start)
    l = @result
    unless _tmp
      self.pos = _save3
      break
    end
    _tmp = apply('attrs', :_attrs)
    a = @result
    unless _tmp
      self.pos = _save3
      break
    end
    _tmp = apply('pts', :_pts)
    unless _tmp
      self.pos = _save3
      break
    end
    _tmp = apply('body', :_body)
    b = @result
    unless _tmp
      self.pos = _save3
      break
    end
    _tmp = apply('pts', :_pts)
    es = @result
    unless _tmp
      self.pos = _save3
      break
    end
    _tmp = apply('end', :_end)
    r = @result
    unless _tmp
      self.pos = _save3
      break
    end
    @result = begin;  "<#{l} #{a}>#{b}#{es}</#{r}>" ; end
    _tmp = true
    unless _tmp
      self.pos = _save3
    end
    break
    end # end sequence

    break if _tmp
    self.pos = _save

    _save4 = self.pos
    while true # sequence
    _tmp = apply('start', :_start)
    l = @result
    unless _tmp
      self.pos = _save4
      break
    end
    _tmp = apply('pts', :_pts)
    s = @result
    unless _tmp
      self.pos = _save4
      break
    end
    _tmp = apply('body', :_body)
    b = @result
    unless _tmp
      self.pos = _save4
      break
    end
    _tmp = apply('pts', :_pts)
    es = @result
    unless _tmp
      self.pos = _save4
      break
    end
    _tmp = apply('end', :_end)
    r = @result
    unless _tmp
      self.pos = _save4
      break
    end
    @result = begin;  "<#{l}>#{s}#{b}#{es}</#{r}>" ; end
    _tmp = true
    unless _tmp
      self.pos = _save4
    end
    break
    end # end sequence

    break if _tmp
    self.pos = _save
    break
    end # end choice

    return _tmp
  end

  # root = doctype? body:b eof { @output = b }
  def _root

    _save = self.pos
    while true # sequence
    _save1 = self.pos
    _tmp = apply('doctype', :_doctype)
    unless _tmp
      _tmp = true
      self.pos = _save1
    end
    unless _tmp
      self.pos = _save
      break
    end
    _tmp = apply('body', :_body)
    b = @result
    unless _tmp
      self.pos = _save
      break
    end
    _tmp = apply('eof', :_eof)
    unless _tmp
      self.pos = _save
      break
    end
    @result = begin;  @output = b ; end
    _tmp = true
    unless _tmp
      self.pos = _save
    end
    break
    end # end sequence

    return _tmp
  end
end
