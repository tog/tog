require 'optparse'
require 'ftools'

module Tog
  class Install
    attr_reader :source_root, :destination_root, :args
    def initialize(runtime_args)
      @args = runtime_args
      parse!(@args)

      @source_root = File.join(File.dirname(__FILE__), '/../../templates')
      @destination_root = ARGV.shift

      usage if options[:help]
    end
    def options
      @options ||= {}
    end
    attr_writer :options

    def run()
      create_files
      add_desert_to_environment
      ['tog_core', 'tog_user', 'tog_social'].each{|plugin|
        Tog::Plugin.new(destination_root, plugin).install
      }
      puts "[done] togified!"
    end

    protected
    def parse!(args)
      self.options = {}

      @option_parser = OptionParser.new do |opt|
        opt.banner = "Usage: #{File.basename($0)} [path]"
        opt.on('-h', '--help', 'Show this help message and quit.') { |v| options[:help] = v }
        opt.parse!(args)
      end
      return args
    end

    def add_desert_to_environment
      sentinel = 'Rails::Initializer.run do |config|'
      puts "desert requirement added to environment.rb"
      gsub_file 'config/environment.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
          "require 'desert'\n#{match}\n"
      end
    end
    
    def gsub_file(relative_destination, regexp, *args, &block)
      path = destination_path(relative_destination)
      content = File.read(path).gsub(regexp, *args, &block)
      File.open(path, 'wb') { |file| file.write(content) }
    end
    
    def destination_path(relative_destination)
      File.join(destination_root, relative_destination)
    end

    def create_files
      files = {
        "lib/tasks/platform.rake.tpl" => "lib/tasks/platform.rake"
      }
      templates_dir = File.join(File.dirname(__FILE__), '/../../templates')
      files.each do |template, file|
        file = File.join(destination_root, file)
        if File.exists?(file)
          warn "[skip] `#{file}' already exists"
        elsif File.exists?(file.downcase)
          warn "[skip] `#{file.downcase}' exists, which could conflict with `#{file}'"
        elsif !File.exists?(File.dirname(file))
          warn "[skip] directory `#{File.dirname(file)}' does not exist"
        else
          puts "[add] writing `#{file}'"
          File.copy(File.join(source_root, template), file)
        end
      end
    end
  end
end