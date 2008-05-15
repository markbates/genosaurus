require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'find'
require 'rubyforge'
require 'rubygems'
require 'rubygems/gem_runner'

GEM_VERSION = "1.1.5"
GEM_NAME = "genosaurus"
GEM_RUBYFORGE_PROJECT = "magrathea"

gem_spec = Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.summary = "#{GEM_NAME}"
  s.description = "Genosaurus is meant to be a very, very easy to use generation system for Ruby."
  s.author = "markbates"
  s.email = "mark@markbates.com"
  s.homepage = "http://www.mackframework.com"

  s.test_files = FileList['test/**/*']

  s.files = FileList['lib/**/*.rb', 'README', 'doc/**/*.*', 'bin/**/*.*']
  s.require_paths << 'lib'

  s.add_dependency("mack_ruby_core_extensions")
  s.add_dependency("erubis")
  s.extra_rdoc_files = ["README"]
  s.has_rdoc = true
  s.rubyforge_project = GEM_RUBYFORGE_PROJECT
end

# rake package
Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
  rm_f FileList['pkg/**/*.*']
end

# rake
desc "Run test code"
Rake::TestTask.new(:default) do |t|
  t.libs << "test"
  t.pattern = '**/*_test.rb'
  t.verbose = true
end

desc "Install the gem"
task :install => :package do |t|
  puts `sudo gem install pkg/#{GEM_NAME}-#{GEM_VERSION}.gem`
end

desc "Release the gem"
task :release => :install do |t|
  begin
    rf = RubyForge.new
    rf.login
    begin
      rf.add_release(GEM_RUBYFORGE_PROJECT, GEM_NAME, GEM_VERSION, File.join("pkg", "#{GEM_NAME}-#{GEM_VERSION}.gem"))
    rescue Exception => e
      if e.message.match("Invalid package_id") || e.message.match("no <package_id> configured for")
        puts "You need to create the package!"
        rf.create_package(GEM_RUBYFORGE_PROJECT, GEM_NAME)
        rf.add_release(GEM_RUBYFORGE_PROJECT, GEM_NAME, GEM_VERSION, File.join("pkg", "#{GEM_NAME}-#{GEM_VERSION}.gem"))
      else
        raise e
      end
    end
  rescue Exception => e
    puts e
  end
end


Rake::RDocTask.new do |rd|
  rd.main = "README"
  files = Dir.glob("**/*.rb")
  files = files.collect {|f| f unless f.match("test/") || f.match("doc/") }.compact
  files << "README"
  rd.rdoc_files = files
  rd.rdoc_dir = "doc"
  rd.options << "--line-numbers"
  rd.options << "--inline-source"
  rd.title = "genosaurus"
end
