require "test/unit"
require 'fileutils'
require File.join(File.dirname(__FILE__), "..", "lib", "genosaurus")
# place common methods, assertions, and other type things in this file so
# other tests will have access to them.

if $genosaurus_output_directory.nil?
  $genosaurus_output_directory = File.join(FileUtils.pwd, "tmp")
  FileUtils.mkdir_p($genosaurus_output_directory)
end

puts "$genosaurus_output_directory: #{$genosaurus_output_directory}"

Dir.glob(File.join(File.dirname(__FILE__), "lib", "**/*.rb")).each {|f| require f}

class Test::Unit::TestCase
  
end