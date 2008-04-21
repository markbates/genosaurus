require 'rubygems'
require 'mack_ruby_core_extensions'
require 'fileutils'
require 'erb'
require 'yaml'


# All generator classes should extend this class if they're expected to be used by the rake generate:<generator_name> task.
# A generator must by name in the following style: <name>Generator. 
# 
# Example:
#   class MyCoolGenerator < Genosaurus
#     require_param :name, :foo
#   end
# 
#   rake generate:my_cool # => calls MyCoolGenerator
class Genosaurus

  include FileUtils
  
  class << self
    
    def run(options = ENV.to_hash)
      gen = self.new(options)
      gen.generate
      gen
    end
    
  end
  
  def initialize(options = {})
    @options = options
    self.class.required_params.each do |p|
      raise ::ArgumentError.new("The required parameter '#{p.to_s.upcase}' is missing for this generator!") unless param(p)
    end
    @generator_name = self.class.name
    @generator_name_underscore = @generator_name.underscore
    @generator_file_path = nil
    @generator_directory_path = nil
    $".each do |f|
      if f.match(/#{@generator_name_underscore}\.rb$/)
        @generator_file_path = f
        @generator_directory_path = File.dirname(@generator_file_path)
      end
    end
    setup
  end
  
  def generator_file_path
    @generator_file_path
  end
  
  def generator_directory_path
    @generator_directory_path
  end
  
  def setup
    # does nothing, unless overridden in subclass.
  end
  
  def before_generate
  end
  
  def after_generate
  end
  
  def manifest
    ivar_cache do 
      yml = File.join(generator_directory_path, "manifest.yml")
      if File.exists?(yml)
        # run using the yml file
        template = ERB.new(File.open(yml).read, nil, "->")
        man = YAML.load(template.result(binding))
      else
        files = Dir.glob(File.join(generator_directory_path, "**/*.template"))
        man = {}
        files.each_with_index do |f, i|
          output_path = f.gsub(File.join(generator_directory_path, "templates"), "")
          output_path.gsub!(".template", "")
          output_path.gsub!(/^\//, "")
          man["template_#{i+1}"] = {
            "type" => File.directory?(f) ? "directory" : "file",
            "template_path" => f,
            "output_path" => ERB.new(output_path, nil, "->").result(binding)
          }
        end
      end
      # puts man.inspect
      man
    end
  end
  
  
  # Used to define arguments that are required by the generator.
  def self.require_param(*args)
    required_params << args
    required_params.flatten!
  end
  
  # Returns the required_params array.
  def self.required_params
    @required_params ||= []
  end

  # Returns a parameter from the initial Hash of parameters.
  def param(key)
    (@options[key.to_s.downcase] ||= @options[key.to_s.upcase])
  end

  # Takes an input_file runs it through ERB and 
  # saves it to the specified output_file. If the output_file exists it will
  # be skipped. If you would like to force the writing of the file, use the
  # :force => true option.
  def template(input_file, output_file, options = @options)
    if File.exists?(output_file)
      unless options[:force]
        puts "Skipped: #{output_file}"
        return
      end
    end
    # incase the directory doesn't exist, let's create it.
    directory(File.dirname(output_file))
    # puts "input_file: #{input_file}"
    # puts "output_file: #{output_file}"
    if $genosaurus_output_directory
      output_file = File.join($genosaurus_output_directory, output_file) 
    end
    File.open(output_file, "w") {|f| f.puts ERB.new(File.open(input_file).read, nil, "->").result(binding)}
    puts "Wrote: #{output_file}"
  end
  
  # Creates the specified directory.
  def directory(output_dir, options = @options)
    if $genosaurus_output_directory
      output_dir = File.join($genosaurus_output_directory, output_dir) 
    end
    if File.exists?(output_dir)
      puts "Exists: #{output_dir}"
      return
    end
    mkdir_p(output_dir)
    puts "Created: #{output_dir}"
  end

  def generate
    generate_callbacks do
      manifest.each_value do |info|
        case info["type"]
        when "file"
          template(info["template_path"], info["output_path"])
        when "directory"
          directory(info["output_path"])
        else
          raise "Unknown 'type': #{info["type"]}!"
        end
      end
    end
  end
  
  private
  def generate_callbacks
    before_generate
    yield
    after_generate
  end
  
end # Genosaurus