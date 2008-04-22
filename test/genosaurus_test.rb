require File.dirname(__FILE__) + '/test_helper.rb'

class GenosaurusBaseTest < Test::Unit::TestCase
  
  def test_simple_implied_generator
    hello_file = File.join($genosaurus_output_directory, "hello_world.rb")
    goodbye_file = File.join($genosaurus_output_directory, "goodbye_world.rb")
    assert !File.exists?(hello_file)
    assert !File.exists?(goodbye_file)
    @generator = HelloGoodbyeGenerator.run("name" => "Mark")
    assert File.exists?(hello_file)
    assert File.exists?(goodbye_file)
    File.open(hello_file, "r") do |f|
      assert_equal "Hello Mark\n", f.read
    end
    File.open(goodbye_file, "r") do |f|
      assert_equal "Goodbye cruel world! Love, Mark\n", f.read
    end
  end

  def test_simple_implied_manifest
    @generator = HelloGoodbyeGenerator.new("name" => "Mark")
    manifest = @generator.manifest
    assert manifest.is_a?(Hash)
    assert_equal 2, manifest.size
    temp1 = manifest["template_1"]
    assert_equal "file", temp1["type"]
    assert_equal File.join(File.dirname(__FILE__), "lib", "hello_goodbye_generator", "templates", "goodbye_world.rb.template"), temp1["template_path"]
    assert_equal "goodbye_world.rb", temp1["output_path"]
    temp2 = manifest["template_2"]
    assert_equal "file", temp2["type"]
    assert_equal File.join(File.dirname(__FILE__), "lib", "hello_goodbye_generator", "templates", "hello_world.rb.template"), temp2["template_path"]
    assert_equal "hello_world.rb", temp2["output_path"]
  end
  
  def test_require_param
    assert_raise(ArgumentError) { HelloGoodbyeGenerator.new }
    @generator = HelloGoodbyeGenerator.new("name" => :foo)
    assert_not_nil @generator
    assert_equal :foo, @generator.param(:name)    
  end
  
  def test_complex_implied_generator
    album_dir = File.join($genosaurus_output_directory, "beatles", "albums")
    lyrics_file = File.join($genosaurus_output_directory, "beatles", "lyrics", "i_am_the_walrus.txt")
    assert !File.exists?(album_dir)
    assert !File.exists?(lyrics_file)
    @generator = IAmTheWalrusGenerator.run("name" => "i_am_the_walrus")
    assert File.exists?(album_dir)
    assert File.exists?(lyrics_file) 
    File.open(lyrics_file, "r") do |f|
      assert_equal "Lyrics for: I Am The Walrus\n", f.read
    end
  end
  
  def test_simple_yml_manifest
    @generator = StrawberryFieldsGenerator.new
    manifest = @generator.manifest
    assert manifest.is_a?(Hash)
    assert_equal 2, manifest.size
    info = manifest["directory_1"]
    assert_equal "beatles/albums/magical_mystery_tour", info["output_path"]
    assert_equal "directory", info["type"]
    info = manifest["template_1"]
    assert_equal File.join(File.dirname(__FILE__), "lib", "strawberry_fields_generator", "templates", "fields.txt"), info["template_path"]
    assert_equal "beatles/albums/magical_mystery_tour/lyrics/strawberry_fields_forever.lyrics", info["output_path"]
  end
  
  def test_directory
    @generator = DirectoryGenerator.run
    assert File.exists?(File.join($genosaurus_output_directory, "months", "january"))
    assert File.exists?(File.join($genosaurus_output_directory, "months", "february"))
    assert File.exists?(File.join($genosaurus_output_directory, "months", "march"))
  end
  
  def clean_tmp
    FileUtils.rm_rf($genosaurus_output_directory, :verbose => false)
  end
  
  def setup
    clean_tmp
  end
  
  def teardown
    clean_tmp
  end
  
end