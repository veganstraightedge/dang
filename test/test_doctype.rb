require 'helper'
require 'doctype'

describe Doctype do
  # based largely on HAML's doctype with a minor variation
  # http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html#doctype_

  it "transforms !!! into html doctype" do
    Dang::it("!!!").must_equal       "<!doctype html>"
    Dang::it("!!! html5").must_equal "<!doctype html>"
  end

  it "transforms HTML4 doctypes" do
    Dang::it("!!! html4").must_equal              '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
    Dang::it("!!! html4 transitional").must_equal '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'
    Dang::it("!!! html4 strict").must_equal       '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
    Dang::it("!!! html4 frameset").must_equal     '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">'
  end

  it "transforms XHTML doctypes" do
    Dang::it("!!! xhtml 1").must_equal              '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
    Dang::it("!!! xhtml 1 transitional").must_equal '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
    Dang::it("!!! xhtml 1 strict").must_equal       '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    Dang::it("!!! xhtml 1 frameset").must_equal     '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
    Dang::it("!!! xhtml 1.1").must_equal            '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
    Dang::it("!!! xhtml 1.1 basic").must_equal      '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
    Dang::it("!!! xhtml 1.2 mobile").must_equal     '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
    Dang::it("!!! xhtml rdfa").must_equal           '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">'
    Dang::it("!!! xhtml 5").must_equal              '<!DOCTYPE html>'
  end

  it "transforms xml utf8 encoding" do
    Dang::it("!!! xml iso-8859-1").must_equal "<?xml version='1.0' encoding='iso-8859-1' ?>"
  end
end
