require "test/unit"
require 'fileutils'
require File.join(File.dirname(__FILE__), "..", "lib", "genosaurus")
# place common methods, assertions, and other type things in this file so
# other tests will have access to them.
PWD = FileUtils.pwd
TMP = File.join(PWD, "tmp")

Dir.glob(File.join(File.dirname(__FILE__), "lib", "**/*.rb")).each {|f| require f}

class Test::Unit::TestCase
  
end