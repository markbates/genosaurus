require "test/unit"
require 'fileutils'
require File.join(File.dirname(__FILE__), "..", "lib", "genosaurus")
# place common methods, assertions, and other type things in this file so
# other tests will have access to them.

TMP = File.join(File.dirname(__FILE__), "tmp")

class Test::Unit::TestCase
  
  def clean_tmp
    FileUtils.rm_rf(TMP)
  end
  
  def setup
    clean_tmp
  end
  
  def teardown
    clean_tmp
  end
  
end