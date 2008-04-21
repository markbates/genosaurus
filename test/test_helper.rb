require "test/unit"
require 'fileutils'
require File.join(File.dirname(__FILE__), "..", "lib", "genosaurus")
# place common methods, assertions, and other type things in this file so
# other tests will have access to them.

TMP = File.join(File.dirname(__FILE__), "tmp")

Dir.glob(File.join(File.dirname(__FILE__), "lib", "**/*.rb")).each {|f| require f}

class Test::Unit::TestCase
  
  def clean_tmp
    FileUtils.rm_rf(TMP)
    FileUtils.mkdir_p(TMP)
    FileUtils.cd(TMP)
  end
  
  def setup
    clean_tmp
  end
  
  def teardown
    clean_tmp
  end
  
end