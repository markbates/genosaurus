module Genosaurus
  # All generator classes should extend this class if they're expected to be used by the rake generate:<generator_name> task.
  # A generator must by name in the following style: <name>Generator. 
  # 
  # Example:
  #   class MyCoolGenerator < Genosaurus::Base
  #     require_param :name, :foo
  #     
  #     def generate
  #       # do work...
  #     end
  #   end
  # 
  #   rake generate:my_cool # => calls MyCoolGenerator
  class Base

    include FileUtils
    
    class << self
      
      def run(options = {})
        gen = self.new(options)
        gen.generate
      end
      
    end
    
    def initialize(options = {})
      @options = options
      self.class.required_params.each do |p|
        raise Genosaurus::Errors::RequiredGeneratorParameterMissing.new(p) unless param(p)
      end
      @generator_name = self.class.name
      @generator_name_underscore = @generator_name.underscore
      @generator_file_path = nil
      @generator_directory_path = nil
      $".each do |f|
        if f.match(/\/#{@generator_name_underscore}\.rb$/)
          @generator_file_path = f
          @generator_directory_path = File.dirname(@generator_file_path)
        end
      end
      setup
    end
    
    def setup
      # does nothing, unless overridden in subclass.
    end
    
    def generate
      man = manifest
      man.each_value do |info|
        puts "info: #{info.inspect}"
        case info["type"]
        when "file"
          template(info["original_path"], info["new_path"])
        when "directory"
          
        else
          raise "Unknown 'type': #{info["type"]}!"
        end
      end
    end
    
    def manifest
      yml = File.join(@generator_file_path, "manifest.yml")
      if File.exists?(yml)
        # run using the yml file
      else
        files = Dir.glob(File.join(@generator_directory_path, "**/*.template"))
        # puts files.inspect
        man = {}
        files.each_with_index do |f, i|
          new_path = f.gsub(File.join(@generator_directory_path, "templates"), "")
          new_path.gsub!(".template", "")
          new_path.gsub!(/^\//, "")
          man["template_#{i+1}"] = {
            "type" => File.directory?(f) ? "directory" : "file",
            "original_path" => f,
            "new_path" => new_path
          }
        end
      end
      # puts man.inspect
      man
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
    # 
    # # Needs to be implemented by the subclass.
    # needs_method :generate
    # 
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
      output_file = ERB.new(output_file).result(binding)
      File.open(output_file, "w") {|f| f.puts ERB.new(File.open(input_file).read, nil, "->").result(binding)}
      puts "Wrote: #{output_file}"
    end
    # 
    # # Creates the specified directory.
    # def directory(output_dir, options = {})
    #   if File.exists?(output_dir)
    #     puts "Exists: #{output_dir}"
    #     return
    #   end
    #   mkdir_p(output_dir)
    #   puts "Created: #{output_dir}"
    # end
    # 
    # def columns(name = param(:name))
    #   ivar_cache("form_columns") do
    #     cs = []
    #     cols = (param(:cols) || param(:columns))
    #     if cols
    #       cols.split(",").each do |x|
    #         cs << Genosaurus::Generator::ModelColumn.new(name, x)
    #       end
    #     end
    #     cs
    #   end
    # end
          
  end # Base
end # Genosaurus