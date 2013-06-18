class Dang::Parser
  # :stopdoc:

    # This is distinct from setup_parser so that a standalone parser
    # can redefine #initialize and still have access to the proper
    # parser setup code.
    def initialize(str, debug=false)
      setup_parser(str, debug)
    end



    # Prepares for parsing +str+.  If you define a custom initialize you must
    # call this method before #parse
    def setup_parser(str, debug=false)
      @string = str
      @pos = 0
      @memoizations = Hash.new { |h,k| h[k] = {} }
      @result = nil
      @failed_rule = nil
      @failing_rule_offset = -1

      setup_foreign_grammar
    end

    attr_reader :string
    attr_reader :failing_rule_offset
    attr_accessor :result, :pos

    
    def current_column(target=pos)
      if c = string.rindex("\n", target-1)
        return target - c - 1
      end

      target + 1
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



    def get_text(start)
      @string[start..@pos-1]
    end

    def show_pos
      width = 10
      if @pos < width
        "#{@pos} (\"#{@string[0,@pos]}\" @ \"#{@string[@pos,width]}\")"
      else
        "#{@pos} (\"... #{@string[@pos - width, width]}\" @ \"#{@string[@pos,width]}\")"
      end
    end

    def failure_info
      l = current_line @failing_rule_offset
      c = current_column @failing_rule_offset

      if @failed_rule.kind_of? Symbol
        info = self.class::Rules[@failed_rule]
        "line #{l}, column #{c}: failed rule '#{info.name}' = '#{info.rendered}'"
      else
        "line #{l}, column #{c}: failed rule '#{@failed_rule}'"
      end
    end

    def failure_caret
      l = current_line @failing_rule_offset
      c = current_column @failing_rule_offset

      line = lines[l-1]
      "#{line}\n#{' ' * (c - 1)}^"
    end

    def failure_character
      l = current_line @failing_rule_offset
      c = current_column @failing_rule_offset
      lines[l-1][c-1, 1]
    end

    def failure_oneline
      l = current_line @failing_rule_offset
      c = current_column @failing_rule_offset

      char = lines[l-1][c-1, 1]

      if @failed_rule.kind_of? Symbol
        info = self.class::Rules[@failed_rule]
        "@#{l}:#{c} failed rule '#{info.name}', got '#{char}'"
      else
        "@#{l}:#{c} failed rule '#{@failed_rule}', got '#{char}'"
      end
    end

    class ParseError < RuntimeError
    end

    def raise_error
      raise ParseError, failure_oneline
    end

    def show_error(io=STDOUT)
      error_pos = @failing_rule_offset
      line_no = current_line(error_pos)
      col_no = current_column(error_pos)

      io.puts "On line #{line_no}, column #{col_no}:"

      if @failed_rule.kind_of? Symbol
        info = self.class::Rules[@failed_rule]
        io.puts "Failed to match '#{info.rendered}' (rule '#{info.name}')"
      else
        io.puts "Failed to match rule '#{@failed_rule}'"
      end

      io.puts "Got: #{string[error_pos,1].inspect}"
      line = lines[line_no-1]
      io.puts "=> #{line}"
      io.print(" " * (col_no + 3))
      io.puts "^"
    end

    def set_failed_rule(name)
      if @pos > @failing_rule_offset
        @failed_rule = name
        @failing_rule_offset = @pos
      end
    end

    attr_reader :failed_rule

    def match_string(str)
      len = str.size
      if @string[pos,len] == str
        @pos += len
        return str
      end

      return nil
    end

    def scan(reg)
      if m = reg.match(@string[@pos..-1])
        width = m.end(0)
        @pos += width
        return true
      end

      return nil
    end

    if "".respond_to? :getbyte
      def get_byte
        if @pos >= @string.size
          return nil
        end

        s = @string.getbyte @pos
        @pos += 1
        s
      end
    else
      def get_byte
        if @pos >= @string.size
          return nil
        end

        s = @string[@pos]
        @pos += 1
        s
      end
    end

    def parse(rule=nil)
      # We invoke the rules indirectly via apply
      # instead of by just calling them as methods because
      # if the rules use left recursion, apply needs to
      # manage that.

      if !rule
        apply(:_root)
      else
        method = rule.gsub("-","_hyphen_")
        apply :"_#{method}"
      end
    end

    class MemoEntry
      def initialize(ans, pos)
        @ans = ans
        @pos = pos
        @result = nil
        @set = false
        @left_rec = false
      end

      attr_reader :ans, :pos, :result, :set
      attr_accessor :left_rec

      def move!(ans, pos, result)
        @ans = ans
        @pos = pos
        @result = result
        @set = true
        @left_rec = false
      end
    end

    def external_invoke(other, rule, *args)
      old_pos = @pos
      old_string = @string

      @pos = other.pos
      @string = other.string

      begin
        if val = __send__(rule, *args)
          other.pos = @pos
          other.result = @result
        else
          other.set_failed_rule "#{self.class}##{rule}"
        end
        val
      ensure
        @pos = old_pos
        @string = old_string
      end
    end

    def apply_with_args(rule, *args)
      memo_key = [rule, args]
      if m = @memoizations[memo_key][@pos]
        @pos = m.pos
        if !m.set
          m.left_rec = true
          return nil
        end

        @result = m.result

        return m.ans
      else
        m = MemoEntry.new(nil, @pos)
        @memoizations[memo_key][@pos] = m
        start_pos = @pos

        ans = __send__ rule, *args

        lr = m.left_rec

        m.move! ans, @pos, @result

        # Don't bother trying to grow the left recursion
        # if it's failing straight away (thus there is no seed)
        if ans and lr
          return grow_lr(rule, args, start_pos, m)
        else
          return ans
        end

        return ans
      end
    end

    def apply(rule)
      if m = @memoizations[rule][@pos]
        @pos = m.pos
        if !m.set
          m.left_rec = true
          return nil
        end

        @result = m.result

        return m.ans
      else
        m = MemoEntry.new(nil, @pos)
        @memoizations[rule][@pos] = m
        start_pos = @pos

        ans = __send__ rule

        lr = m.left_rec

        m.move! ans, @pos, @result

        # Don't bother trying to grow the left recursion
        # if it's failing straight away (thus there is no seed)
        if ans and lr
          return grow_lr(rule, nil, start_pos, m)
        else
          return ans
        end

        return ans
      end
    end

    def grow_lr(rule, args, start_pos, m)
      while true
        @pos = start_pos
        @result = m.result

        if args
          ans = __send__ rule, *args
        else
          ans = __send__ rule
        end
        return nil unless ans

        break if @pos <= m.pos

        m.move! ans, @pos, @result
      end

      @result = m.result
      @pos = m.pos
      return m.ans
    end

    class RuleInfo
      def initialize(name, rendered)
        @name = name
        @rendered = rendered
      end

      attr_reader :name, :rendered
    end

    def self.rule_info(name, rendered)
      RuleInfo.new(name, rendered)
    end


  # :startdoc:


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

  def output(env=nil)
    doctype = html_doctype

    strings = @output.flatten.map do |i|
      case i
      when Literal
        "_out << #{i.str.dump}"
      when Code
        if i.print
          "_out << (#{i.str}).to_s"
        else
          i.str
        end
      when Filter
        "_out << Dang.run_filter('#{i.name}', #{i.str.dump}).to_s"
      end
    end

    code = "_out = '';\n" + strings.join(";") + ";_out"

    out = eval(code, env || binding).strip

    if doctype.empty?
      str = out
    else
      if out.empty?
        str = doctype
      else
        str = doctype << "\n" << out
      end
    end

    str
  end

  def attrs(at,sel=[])
    out = []
    classes = []

    (at+sel).each do |key,val|
      if key == "class"
        classes.unshift val
      elsif val == true
        out << "#{key}"
      else
        out << "#{key}='#{val}'"
      end
    end

    unless classes.empty?
      out.unshift "class='#{classes.join(' ')}'"
    end

    out.join(' ')
  end

  class Literal
    def initialize(str)
      @str = str
    end

    attr_reader :str
  end

  class Code
    def initialize(str, print)
      @str = str
      @print = print
    end

    attr_reader :str, :print
  end

  class Filter
    def initialize(name, str)
      @name = name
      @str = str
    end

    attr_reader :name, :str
  end

  def joinm(*elems)
    elems.map do |i|
      if i.kind_of? String
        Literal.new(i)
      else
        i
      end
    end
  end

  def join(f,b)
    f = Literal.new(f) if f.kind_of? String
    b = Literal.new(b) if b.kind_of? String

    if b.kind_of? Array
      [f] + b
    else
      [f,b]
    end
  end

  def code(str, print=true)
    Code.new(str, print)
  end


  # :stopdoc:
  def setup_foreign_grammar; end

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

    set_failed_rule :_space unless _tmp
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

    set_failed_rule :_bs unless _tmp
    return _tmp
  end

  # - = bs+
  def __hyphen_
    _save = self.pos
    _tmp = apply(:_bs)
    if _tmp
      while true
        _tmp = apply(:_bs)
        break unless _tmp
      end
      _tmp = true
    else
      self.pos = _save
    end
    set_failed_rule :__hyphen_ unless _tmp
    return _tmp
  end

  # eol = "\n"
  def _eol
    _tmp = match_string("\n")
    set_failed_rule :_eol unless _tmp
    return _tmp
  end

  # eof = !.
  def _eof
    _save = self.pos
    _tmp = get_byte
    _tmp = _tmp ? nil : true
    self.pos = _save
    set_failed_rule :_eof unless _tmp
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
          _tmp = apply(:_eol)
          _tmp = _tmp ? nil : true
          self.pos = _save3
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
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end

      _save4 = self.pos
      while true # choice
        _tmp = apply(:_eol)
        break if _tmp
        self.pos = _save4
        _tmp = apply(:_eof)
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

    set_failed_rule :_rest unless _tmp
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
        _tmp = apply(:_space)
        break unless _tmp
      end
      _tmp = true
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_rest)
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

    set_failed_rule :_doctype unless _tmp
    return _tmp
  end

  # name = < /[a-zA-Z0-9_\-:]+/ > { text }
  def _name

    _save = self.pos
    while true # sequence
      _text_start = self.pos
      _tmp = scan(/\A(?-mix:[a-zA-Z0-9_\-:]+)/)
      if _tmp
        text = get_text(_text_start)
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

    set_failed_rule :_name unless _tmp
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
      _tmp = apply(:_name)
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

    set_failed_rule :_start unless _tmp
    return _tmp
  end

  # pts = (space+ { "" } | < eol bs* > { text })
  def _pts

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _save2 = self.pos
        _tmp = apply(:_space)
        if _tmp
          while true
            _tmp = apply(:_space)
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
          _tmp = apply(:_eol)
          unless _tmp
            self.pos = _save4
            break
          end
          while true
            _tmp = apply(:_bs)
            break unless _tmp
          end
          _tmp = true
          unless _tmp
            self.pos = _save4
          end
          break
        end # end sequence

        if _tmp
          text = get_text(_text_start)
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

    set_failed_rule :_pts unless _tmp
    return _tmp
  end

  # end = name:n ">" { n }
  def _end

    _save = self.pos
    while true # sequence
      _tmp = apply(:_name)
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

    set_failed_rule :_end unless _tmp
    return _tmp
  end

  # slash = - "/>"
  def _slash

    _save = self.pos
    while true # sequence
      _tmp = apply(:__hyphen_)
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

    set_failed_rule :_slash unless _tmp
    return _tmp
  end

  # marker = (start | "<!" | - end)
  def _marker

    _save = self.pos
    while true # choice
      _tmp = apply(:_start)
      break if _tmp
      self.pos = _save
      _tmp = match_string("<!")
      break if _tmp
      self.pos = _save

      _save1 = self.pos
      while true # sequence
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:_end)
        unless _tmp
          self.pos = _save1
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_marker unless _tmp
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
          _tmp = apply(:_marker)
          _tmp = _tmp ? nil : true
          self.pos = _save3
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
        text = get_text(_text_start)
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

    set_failed_rule :_chunk unless _tmp
    return _tmp
  end

  # rclose = "->"
  def _rclose
    _tmp = match_string("->")
    set_failed_rule :_rclose unless _tmp
    return _tmp
  end

  # ruby = "<-" < (!rclose .)* > rclose { code(text, false) }
  def _ruby

    _save = self.pos
    while true # sequence
      _tmp = match_string("<-")
      unless _tmp
        self.pos = _save
        break
      end
      _text_start = self.pos
      while true

        _save2 = self.pos
        while true # sequence
          _save3 = self.pos
          _tmp = apply(:_rclose)
          _tmp = _tmp ? nil : true
          self.pos = _save3
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
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_rclose)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  code(text, false) ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_ruby unless _tmp
    return _tmp
  end

  # pclose = "=>"
  def _pclose
    _tmp = match_string("=>")
    set_failed_rule :_pclose unless _tmp
    return _tmp
  end

  # puby = "<=" < (!pclose .)* > pclose { code(text) }
  def _puby

    _save = self.pos
    while true # sequence
      _tmp = match_string("<=")
      unless _tmp
        self.pos = _save
        break
      end
      _text_start = self.pos
      while true

        _save2 = self.pos
        while true # sequence
          _save3 = self.pos
          _tmp = apply(:_pclose)
          _tmp = _tmp ? nil : true
          self.pos = _save3
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
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_pclose)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  code(text) ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_puby unless _tmp
    return _tmp
  end

  # part = (ruby | puby | filter | comment | tag | chunk)
  def _part

    _save = self.pos
    while true # choice
      _tmp = apply(:_ruby)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_puby)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_filter)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_comment)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_tag)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_chunk)
      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_part unless _tmp
    return _tmp
  end

  # body = (part:p body:b { join(p,b) } | part)
  def _body

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _tmp = apply(:_part)
        p = @result
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:_body)
        b = @result
        unless _tmp
          self.pos = _save1
          break
        end
        @result = begin;  join(p,b) ; end
        _tmp = true
        unless _tmp
          self.pos = _save1
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save
      _tmp = apply(:_part)
      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_body unless _tmp
    return _tmp
  end

  # key = (name | "'" < /[^'\n]*/ > "'" { text })
  def _key

    _save = self.pos
    while true # choice
      _tmp = apply(:_name)
      break if _tmp
      self.pos = _save

      _save1 = self.pos
      while true # sequence
        _tmp = match_string("'")
        unless _tmp
          self.pos = _save1
          break
        end
        _text_start = self.pos
        _tmp = scan(/\A(?-mix:[^'\n]*)/)
        if _tmp
          text = get_text(_text_start)
        end
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = match_string("'")
        unless _tmp
          self.pos = _save1
          break
        end
        @result = begin;  text ; end
        _tmp = true
        unless _tmp
          self.pos = _save1
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_key unless _tmp
    return _tmp
  end

  # val = ("'" < /[^'\n]*/ > "'" { text } | < (!"]" .)* > { text })
  def _val

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _tmp = match_string("'")
        unless _tmp
          self.pos = _save1
          break
        end
        _text_start = self.pos
        _tmp = scan(/\A(?-mix:[^'\n]*)/)
        if _tmp
          text = get_text(_text_start)
        end
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = match_string("'")
        unless _tmp
          self.pos = _save1
          break
        end
        @result = begin;  text ; end
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
        _text_start = self.pos
        while true

          _save4 = self.pos
          while true # sequence
            _save5 = self.pos
            _tmp = match_string("]")
            _tmp = _tmp ? nil : true
            self.pos = _save5
            unless _tmp
              self.pos = _save4
              break
            end
            _tmp = get_byte
            unless _tmp
              self.pos = _save4
            end
            break
          end # end sequence

          break unless _tmp
        end
        _tmp = true
        if _tmp
          text = get_text(_text_start)
        end
        unless _tmp
          self.pos = _save2
          break
        end
        @result = begin;  text ; end
        _tmp = true
        unless _tmp
          self.pos = _save2
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_val unless _tmp
    return _tmp
  end

  # dattr = "[" key:k "=" val:v "]" { "data-#{k}='#{v}'" }
  def _dattr

    _save = self.pos
    while true # sequence
      _tmp = match_string("[")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_key)
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
      _tmp = apply(:_val)
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
      @result = begin;  "data-#{k}='#{v}'" ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_dattr unless _tmp
    return _tmp
  end

  # dattrs = (dattr:a dattrs:l { "#{a} #{l}" } | dattr)
  def _dattrs

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _tmp = apply(:_dattr)
        a = @result
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:_dattrs)
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
      _tmp = apply(:_dattr)
      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_dattrs unless _tmp
    return _tmp
  end

  # attr = ("[data" dattrs:t "]" { [t,true] } | "[" key:k "=" val:v "]" { [k, v] } | "[" key:k "]" { [k,true] })
  def _attr

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _tmp = match_string("[data")
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:_dattrs)
        t = @result
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = match_string("]")
        unless _tmp
          self.pos = _save1
          break
        end
        @result = begin;  [t,true] ; end
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
        _tmp = match_string("[")
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = apply(:_key)
        k = @result
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = match_string("=")
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = apply(:_val)
        v = @result
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = match_string("]")
        unless _tmp
          self.pos = _save2
          break
        end
        @result = begin;  [k, v] ; end
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
        _tmp = match_string("[")
        unless _tmp
          self.pos = _save3
          break
        end
        _tmp = apply(:_key)
        k = @result
        unless _tmp
          self.pos = _save3
          break
        end
        _tmp = match_string("]")
        unless _tmp
          self.pos = _save3
          break
        end
        @result = begin;  [k,true] ; end
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

    set_failed_rule :_attr unless _tmp
    return _tmp
  end

  # attrs = (attr:a attrs:l { [a] + l } | attr:a { [a] })
  def _attrs

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _tmp = apply(:_attr)
        a = @result
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:_attrs)
        l = @result
        unless _tmp
          self.pos = _save1
          break
        end
        @result = begin;  [a] + l ; end
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
        _tmp = apply(:_attr)
        a = @result
        unless _tmp
          self.pos = _save2
          break
        end
        @result = begin;  [a] ; end
        _tmp = true
        unless _tmp
          self.pos = _save2
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_attrs unless _tmp
    return _tmp
  end

  # cc_if = /[iI][fF]/
  def _cc_if
    _tmp = scan(/\A(?-mix:[iI][fF])/)
    set_failed_rule :_cc_if unless _tmp
    return _tmp
  end

  # cc_end = /[eE][nN][dD][iI][fF]/
  def _cc_end
    _tmp = scan(/\A(?-mix:[eE][nN][dD][iI][fF])/)
    set_failed_rule :_cc_end unless _tmp
    return _tmp
  end

  # comment = ("<!" space+ < "[" space* cc_if (!"]" .)* "]" > space+ "!>" { "<!--#{text}>" } | "<!" space+ < "[" space* cc_end (!"]" .)* "]" > space+ "!>" { "<!#{text}-->" } | "<!" < (!"!>" .)* > "!>" { "<!--#{text}-->" })
  def _comment

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _tmp = match_string("<!")
        unless _tmp
          self.pos = _save1
          break
        end
        _save2 = self.pos
        _tmp = apply(:_space)
        if _tmp
          while true
            _tmp = apply(:_space)
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
        _text_start = self.pos

        _save3 = self.pos
        while true # sequence
          _tmp = match_string("[")
          unless _tmp
            self.pos = _save3
            break
          end
          while true
            _tmp = apply(:_space)
            break unless _tmp
          end
          _tmp = true
          unless _tmp
            self.pos = _save3
            break
          end
          _tmp = apply(:_cc_if)
          unless _tmp
            self.pos = _save3
            break
          end
          while true

            _save6 = self.pos
            while true # sequence
              _save7 = self.pos
              _tmp = match_string("]")
              _tmp = _tmp ? nil : true
              self.pos = _save7
              unless _tmp
                self.pos = _save6
                break
              end
              _tmp = get_byte
              unless _tmp
                self.pos = _save6
              end
              break
            end # end sequence

            break unless _tmp
          end
          _tmp = true
          unless _tmp
            self.pos = _save3
            break
          end
          _tmp = match_string("]")
          unless _tmp
            self.pos = _save3
          end
          break
        end # end sequence

        if _tmp
          text = get_text(_text_start)
        end
        unless _tmp
          self.pos = _save1
          break
        end
        _save8 = self.pos
        _tmp = apply(:_space)
        if _tmp
          while true
            _tmp = apply(:_space)
            break unless _tmp
          end
          _tmp = true
        else
          self.pos = _save8
        end
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = match_string("!>")
        unless _tmp
          self.pos = _save1
          break
        end
        @result = begin;  "<!--#{text}>" ; end
        _tmp = true
        unless _tmp
          self.pos = _save1
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save9 = self.pos
      while true # sequence
        _tmp = match_string("<!")
        unless _tmp
          self.pos = _save9
          break
        end
        _save10 = self.pos
        _tmp = apply(:_space)
        if _tmp
          while true
            _tmp = apply(:_space)
            break unless _tmp
          end
          _tmp = true
        else
          self.pos = _save10
        end
        unless _tmp
          self.pos = _save9
          break
        end
        _text_start = self.pos

        _save11 = self.pos
        while true # sequence
          _tmp = match_string("[")
          unless _tmp
            self.pos = _save11
            break
          end
          while true
            _tmp = apply(:_space)
            break unless _tmp
          end
          _tmp = true
          unless _tmp
            self.pos = _save11
            break
          end
          _tmp = apply(:_cc_end)
          unless _tmp
            self.pos = _save11
            break
          end
          while true

            _save14 = self.pos
            while true # sequence
              _save15 = self.pos
              _tmp = match_string("]")
              _tmp = _tmp ? nil : true
              self.pos = _save15
              unless _tmp
                self.pos = _save14
                break
              end
              _tmp = get_byte
              unless _tmp
                self.pos = _save14
              end
              break
            end # end sequence

            break unless _tmp
          end
          _tmp = true
          unless _tmp
            self.pos = _save11
            break
          end
          _tmp = match_string("]")
          unless _tmp
            self.pos = _save11
          end
          break
        end # end sequence

        if _tmp
          text = get_text(_text_start)
        end
        unless _tmp
          self.pos = _save9
          break
        end
        _save16 = self.pos
        _tmp = apply(:_space)
        if _tmp
          while true
            _tmp = apply(:_space)
            break unless _tmp
          end
          _tmp = true
        else
          self.pos = _save16
        end
        unless _tmp
          self.pos = _save9
          break
        end
        _tmp = match_string("!>")
        unless _tmp
          self.pos = _save9
          break
        end
        @result = begin;  "<!#{text}-->" ; end
        _tmp = true
        unless _tmp
          self.pos = _save9
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save17 = self.pos
      while true # sequence
        _tmp = match_string("<!")
        unless _tmp
          self.pos = _save17
          break
        end
        _text_start = self.pos
        while true

          _save19 = self.pos
          while true # sequence
            _save20 = self.pos
            _tmp = match_string("!>")
            _tmp = _tmp ? nil : true
            self.pos = _save20
            unless _tmp
              self.pos = _save19
              break
            end
            _tmp = get_byte
            unless _tmp
              self.pos = _save19
            end
            break
          end # end sequence

          break unless _tmp
        end
        _tmp = true
        if _tmp
          text = get_text(_text_start)
        end
        unless _tmp
          self.pos = _save17
          break
        end
        _tmp = match_string("!>")
        unless _tmp
          self.pos = _save17
          break
        end
        @result = begin;  "<!--#{text}-->" ; end
        _tmp = true
        unless _tmp
          self.pos = _save17
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_comment unless _tmp
    return _tmp
  end

  # simple = /[a-zA-Z0-9_\-]+/
  def _simple
    _tmp = scan(/\A(?-mix:[a-zA-Z0-9_\-]+)/)
    set_failed_rule :_simple unless _tmp
    return _tmp
  end

  # select = ("#" < simple > { ["id", text] } | "." < simple > { ["class", text] })
  def _select

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _tmp = match_string("#")
        unless _tmp
          self.pos = _save1
          break
        end
        _text_start = self.pos
        _tmp = apply(:_simple)
        if _tmp
          text = get_text(_text_start)
        end
        unless _tmp
          self.pos = _save1
          break
        end
        @result = begin;  ["id", text] ; end
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
        _tmp = match_string(".")
        unless _tmp
          self.pos = _save2
          break
        end
        _text_start = self.pos
        _tmp = apply(:_simple)
        if _tmp
          text = get_text(_text_start)
        end
        unless _tmp
          self.pos = _save2
          break
        end
        @result = begin;  ["class", text] ; end
        _tmp = true
        unless _tmp
          self.pos = _save2
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_select unless _tmp
    return _tmp
  end

  # selects = (select:s selects:t { [s] + t } | select:s { [s] })
  def _selects

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _tmp = apply(:_select)
        s = @result
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:_selects)
        t = @result
        unless _tmp
          self.pos = _save1
          break
        end
        @result = begin;  [s] + t ; end
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
        _tmp = apply(:_select)
        s = @result
        unless _tmp
          self.pos = _save2
          break
        end
        @result = begin;  [s] ; end
        _tmp = true
        unless _tmp
          self.pos = _save2
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_selects unless _tmp
    return _tmp
  end

  # end_filter = bs* < /[a-zA-Z]+/ > &{ n == text } ":>"
  def _end_filter(n)

    _save = self.pos
    while true # sequence
      while true
        _tmp = apply(:_bs)
        break unless _tmp
      end
      _tmp = true
      unless _tmp
        self.pos = _save
        break
      end
      _text_start = self.pos
      _tmp = scan(/\A(?-mix:[a-zA-Z]+)/)
      if _tmp
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      _save2 = self.pos
      _tmp = begin;  n == text ; end
      self.pos = _save2
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string(":>")
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_end_filter unless _tmp
    return _tmp
  end

  # filter = "<:" name:n bs* < (!end_filter(n) .)* > end_filter(n) { Filter.new(n, text) }
  def _filter

    _save = self.pos
    while true # sequence
      _tmp = match_string("<:")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_name)
      n = @result
      unless _tmp
        self.pos = _save
        break
      end
      while true
        _tmp = apply(:_bs)
        break unless _tmp
      end
      _tmp = true
      unless _tmp
        self.pos = _save
        break
      end
      _text_start = self.pos
      while true

        _save3 = self.pos
        while true # sequence
          _save4 = self.pos
          _tmp = apply_with_args(:_end_filter, n)
          _tmp = _tmp ? nil : true
          self.pos = _save4
          unless _tmp
            self.pos = _save3
            break
          end
          _tmp = get_byte
          unless _tmp
            self.pos = _save3
          end
          break
        end # end sequence

        break unless _tmp
      end
      _tmp = true
      if _tmp
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply_with_args(:_end_filter, n)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  Filter.new(n, text) ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_filter unless _tmp
    return _tmp
  end

  # tag = (start:l slash { "<#{l} />" } | start:l space+ end:r { "<#{l}></#{r}>" } | start:l attrs:a slash { "<#{l} #{attrs(a)} />" } | start:l selects:t slash { "<#{l} #{attrs(t)} />" } | start:l selects:t attrs:a slash { "<#{l} #{attrs(t,a)} />" } | start:l attrs:a space+ end:r { "<#{l} #{attrs(a)}></#{r}>" } | start:l selects:t space+ end:r { "<#{l} #{attrs(t)}></#{r}>" } | start:l selects:t attrs:a space+ end:r { "<#{l} #{attrs(t,a)}></#{r}>" } | start:l selects:t attrs:a pts body:b pts:es end:r { joinm "<#{l} #{attrs(a,t)}>",b,es,"</#{r}>" } | start:l attrs:a pts body:b pts:es end:r { joinm "<#{l} #{attrs(a)}>", b, es, "</#{r}>" } | start:l selects:t pts:s body:b pts:es end:r { joinm "<#{l} #{attrs(t)}>",s, b, es, "</#{r}>" } | start:l pts:s body:b pts:es end:r { joinm "<#{l}>", s, b, es, "</#{r}>" })
  def _tag

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:_slash)
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
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save2
          break
        end
        _save3 = self.pos
        _tmp = apply(:_space)
        if _tmp
          while true
            _tmp = apply(:_space)
            break unless _tmp
          end
          _tmp = true
        else
          self.pos = _save3
        end
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = apply(:_end)
        r = @result
        unless _tmp
          self.pos = _save2
          break
        end
        @result = begin;  "<#{l}></#{r}>" ; end
        _tmp = true
        unless _tmp
          self.pos = _save2
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save4 = self.pos
      while true # sequence
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save4
          break
        end
        _tmp = apply(:_attrs)
        a = @result
        unless _tmp
          self.pos = _save4
          break
        end
        _tmp = apply(:_slash)
        unless _tmp
          self.pos = _save4
          break
        end
        @result = begin;  "<#{l} #{attrs(a)} />" ; end
        _tmp = true
        unless _tmp
          self.pos = _save4
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save5 = self.pos
      while true # sequence
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save5
          break
        end
        _tmp = apply(:_selects)
        t = @result
        unless _tmp
          self.pos = _save5
          break
        end
        _tmp = apply(:_slash)
        unless _tmp
          self.pos = _save5
          break
        end
        @result = begin;  "<#{l} #{attrs(t)} />" ; end
        _tmp = true
        unless _tmp
          self.pos = _save5
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save6 = self.pos
      while true # sequence
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save6
          break
        end
        _tmp = apply(:_selects)
        t = @result
        unless _tmp
          self.pos = _save6
          break
        end
        _tmp = apply(:_attrs)
        a = @result
        unless _tmp
          self.pos = _save6
          break
        end
        _tmp = apply(:_slash)
        unless _tmp
          self.pos = _save6
          break
        end
        @result = begin;  "<#{l} #{attrs(t,a)} />" ; end
        _tmp = true
        unless _tmp
          self.pos = _save6
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save7 = self.pos
      while true # sequence
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save7
          break
        end
        _tmp = apply(:_attrs)
        a = @result
        unless _tmp
          self.pos = _save7
          break
        end
        _save8 = self.pos
        _tmp = apply(:_space)
        if _tmp
          while true
            _tmp = apply(:_space)
            break unless _tmp
          end
          _tmp = true
        else
          self.pos = _save8
        end
        unless _tmp
          self.pos = _save7
          break
        end
        _tmp = apply(:_end)
        r = @result
        unless _tmp
          self.pos = _save7
          break
        end
        @result = begin;  "<#{l} #{attrs(a)}></#{r}>" ; end
        _tmp = true
        unless _tmp
          self.pos = _save7
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save9 = self.pos
      while true # sequence
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save9
          break
        end
        _tmp = apply(:_selects)
        t = @result
        unless _tmp
          self.pos = _save9
          break
        end
        _save10 = self.pos
        _tmp = apply(:_space)
        if _tmp
          while true
            _tmp = apply(:_space)
            break unless _tmp
          end
          _tmp = true
        else
          self.pos = _save10
        end
        unless _tmp
          self.pos = _save9
          break
        end
        _tmp = apply(:_end)
        r = @result
        unless _tmp
          self.pos = _save9
          break
        end
        @result = begin;  "<#{l} #{attrs(t)}></#{r}>" ; end
        _tmp = true
        unless _tmp
          self.pos = _save9
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save11 = self.pos
      while true # sequence
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save11
          break
        end
        _tmp = apply(:_selects)
        t = @result
        unless _tmp
          self.pos = _save11
          break
        end
        _tmp = apply(:_attrs)
        a = @result
        unless _tmp
          self.pos = _save11
          break
        end
        _save12 = self.pos
        _tmp = apply(:_space)
        if _tmp
          while true
            _tmp = apply(:_space)
            break unless _tmp
          end
          _tmp = true
        else
          self.pos = _save12
        end
        unless _tmp
          self.pos = _save11
          break
        end
        _tmp = apply(:_end)
        r = @result
        unless _tmp
          self.pos = _save11
          break
        end
        @result = begin;  "<#{l} #{attrs(t,a)}></#{r}>" ; end
        _tmp = true
        unless _tmp
          self.pos = _save11
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save13 = self.pos
      while true # sequence
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save13
          break
        end
        _tmp = apply(:_selects)
        t = @result
        unless _tmp
          self.pos = _save13
          break
        end
        _tmp = apply(:_attrs)
        a = @result
        unless _tmp
          self.pos = _save13
          break
        end
        _tmp = apply(:_pts)
        unless _tmp
          self.pos = _save13
          break
        end
        _tmp = apply(:_body)
        b = @result
        unless _tmp
          self.pos = _save13
          break
        end
        _tmp = apply(:_pts)
        es = @result
        unless _tmp
          self.pos = _save13
          break
        end
        _tmp = apply(:_end)
        r = @result
        unless _tmp
          self.pos = _save13
          break
        end
        @result = begin;  joinm "<#{l} #{attrs(a,t)}>",b,es,"</#{r}>" ; end
        _tmp = true
        unless _tmp
          self.pos = _save13
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save14 = self.pos
      while true # sequence
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save14
          break
        end
        _tmp = apply(:_attrs)
        a = @result
        unless _tmp
          self.pos = _save14
          break
        end
        _tmp = apply(:_pts)
        unless _tmp
          self.pos = _save14
          break
        end
        _tmp = apply(:_body)
        b = @result
        unless _tmp
          self.pos = _save14
          break
        end
        _tmp = apply(:_pts)
        es = @result
        unless _tmp
          self.pos = _save14
          break
        end
        _tmp = apply(:_end)
        r = @result
        unless _tmp
          self.pos = _save14
          break
        end
        @result = begin;  joinm "<#{l} #{attrs(a)}>", b, es, "</#{r}>" ; end
        _tmp = true
        unless _tmp
          self.pos = _save14
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save15 = self.pos
      while true # sequence
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save15
          break
        end
        _tmp = apply(:_selects)
        t = @result
        unless _tmp
          self.pos = _save15
          break
        end
        _tmp = apply(:_pts)
        s = @result
        unless _tmp
          self.pos = _save15
          break
        end
        _tmp = apply(:_body)
        b = @result
        unless _tmp
          self.pos = _save15
          break
        end
        _tmp = apply(:_pts)
        es = @result
        unless _tmp
          self.pos = _save15
          break
        end
        _tmp = apply(:_end)
        r = @result
        unless _tmp
          self.pos = _save15
          break
        end
        @result = begin;  joinm "<#{l} #{attrs(t)}>",s, b, es, "</#{r}>" ; end
        _tmp = true
        unless _tmp
          self.pos = _save15
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save16 = self.pos
      while true # sequence
        _tmp = apply(:_start)
        l = @result
        unless _tmp
          self.pos = _save16
          break
        end
        _tmp = apply(:_pts)
        s = @result
        unless _tmp
          self.pos = _save16
          break
        end
        _tmp = apply(:_body)
        b = @result
        unless _tmp
          self.pos = _save16
          break
        end
        _tmp = apply(:_pts)
        es = @result
        unless _tmp
          self.pos = _save16
          break
        end
        _tmp = apply(:_end)
        r = @result
        unless _tmp
          self.pos = _save16
          break
        end
        @result = begin;  joinm "<#{l}>", s, b, es, "</#{r}>" ; end
        _tmp = true
        unless _tmp
          self.pos = _save16
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_tag unless _tmp
    return _tmp
  end

  # root = doctype? body:b eof { @output = join(b,"") }
  def _root

    _save = self.pos
    while true # sequence
      _save1 = self.pos
      _tmp = apply(:_doctype)
      unless _tmp
        _tmp = true
        self.pos = _save1
      end
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_body)
      b = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_eof)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  @output = join(b,"") ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_root unless _tmp
    return _tmp
  end

  Rules = {}
  Rules[:_space] = rule_info("space", "(\" \" | \"\\t\")")
  Rules[:_bs] = rule_info("bs", "(\" \" | \"\\t\" | \"\\n\")")
  Rules[:__hyphen_] = rule_info("-", "bs+")
  Rules[:_eol] = rule_info("eol", "\"\\n\"")
  Rules[:_eof] = rule_info("eof", "!.")
  Rules[:_rest] = rule_info("rest", "< (!eol .)* > (eol | eof) { text }")
  Rules[:_doctype] = rule_info("doctype", "\"!!!\" space* rest:r { @doctype = r.empty? ? \"html\" : r }")
  Rules[:_name] = rule_info("name", "< /[a-zA-Z0-9_\\-:]+/ > { text }")
  Rules[:_start] = rule_info("start", "\"<\" name:n { n }")
  Rules[:_pts] = rule_info("pts", "(space+ { \"\" } | < eol bs* > { text })")
  Rules[:_end] = rule_info("end", "name:n \">\" { n }")
  Rules[:_slash] = rule_info("slash", "- \"/>\"")
  Rules[:_marker] = rule_info("marker", "(start | \"<!\" | - end)")
  Rules[:_chunk] = rule_info("chunk", "< (!marker .)* > { text }")
  Rules[:_rclose] = rule_info("rclose", "\"->\"")
  Rules[:_ruby] = rule_info("ruby", "\"<-\" < (!rclose .)* > rclose { code(text, false) }")
  Rules[:_pclose] = rule_info("pclose", "\"=>\"")
  Rules[:_puby] = rule_info("puby", "\"<=\" < (!pclose .)* > pclose { code(text) }")
  Rules[:_part] = rule_info("part", "(ruby | puby | filter | comment | tag | chunk)")
  Rules[:_body] = rule_info("body", "(part:p body:b { join(p,b) } | part)")
  Rules[:_key] = rule_info("key", "(name | \"'\" < /[^'\\n]*/ > \"'\" { text })")
  Rules[:_val] = rule_info("val", "(\"'\" < /[^'\\n]*/ > \"'\" { text } | < (!\"]\" .)* > { text })")
  Rules[:_dattr] = rule_info("dattr", "\"[\" key:k \"=\" val:v \"]\" { \"data-\#{k}='\#{v}'\" }")
  Rules[:_dattrs] = rule_info("dattrs", "(dattr:a dattrs:l { \"\#{a} \#{l}\" } | dattr)")
  Rules[:_attr] = rule_info("attr", "(\"[data\" dattrs:t \"]\" { [t,true] } | \"[\" key:k \"=\" val:v \"]\" { [k, v] } | \"[\" key:k \"]\" { [k,true] })")
  Rules[:_attrs] = rule_info("attrs", "(attr:a attrs:l { [a] + l } | attr:a { [a] })")
  Rules[:_cc_if] = rule_info("cc_if", "/[iI][fF]/")
  Rules[:_cc_end] = rule_info("cc_end", "/[eE][nN][dD][iI][fF]/")
  Rules[:_comment] = rule_info("comment", "(\"<!\" space+ < \"[\" space* cc_if (!\"]\" .)* \"]\" > space+ \"!>\" { \"<!--\#{text}>\" } | \"<!\" space+ < \"[\" space* cc_end (!\"]\" .)* \"]\" > space+ \"!>\" { \"<!\#{text}-->\" } | \"<!\" < (!\"!>\" .)* > \"!>\" { \"<!--\#{text}-->\" })")
  Rules[:_simple] = rule_info("simple", "/[a-zA-Z0-9_\\-]+/")
  Rules[:_select] = rule_info("select", "(\"\#\" < simple > { [\"id\", text] } | \".\" < simple > { [\"class\", text] })")
  Rules[:_selects] = rule_info("selects", "(select:s selects:t { [s] + t } | select:s { [s] })")
  Rules[:_end_filter] = rule_info("end_filter", "bs* < /[a-zA-Z]+/ > &{ n == text } \":>\"")
  Rules[:_filter] = rule_info("filter", "\"<:\" name:n bs* < (!end_filter(n) .)* > end_filter(n) { Filter.new(n, text) }")
  Rules[:_tag] = rule_info("tag", "(start:l slash { \"<\#{l} />\" } | start:l space+ end:r { \"<\#{l}></\#{r}>\" } | start:l attrs:a slash { \"<\#{l} \#{attrs(a)} />\" } | start:l selects:t slash { \"<\#{l} \#{attrs(t)} />\" } | start:l selects:t attrs:a slash { \"<\#{l} \#{attrs(t,a)} />\" } | start:l attrs:a space+ end:r { \"<\#{l} \#{attrs(a)}></\#{r}>\" } | start:l selects:t space+ end:r { \"<\#{l} \#{attrs(t)}></\#{r}>\" } | start:l selects:t attrs:a space+ end:r { \"<\#{l} \#{attrs(t,a)}></\#{r}>\" } | start:l selects:t attrs:a pts body:b pts:es end:r { joinm \"<\#{l} \#{attrs(a,t)}>\",b,es,\"</\#{r}>\" } | start:l attrs:a pts body:b pts:es end:r { joinm \"<\#{l} \#{attrs(a)}>\", b, es, \"</\#{r}>\" } | start:l selects:t pts:s body:b pts:es end:r { joinm \"<\#{l} \#{attrs(t)}>\",s, b, es, \"</\#{r}>\" } | start:l pts:s body:b pts:es end:r { joinm \"<\#{l}>\", s, b, es, \"</\#{r}>\" })")
  Rules[:_root] = rule_info("root", "doctype? body:b eof { @output = join(b,\"\") }")
  # :startdoc:
end
