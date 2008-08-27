class TogifyGenerator < RubiGen::Base

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  default_options :author => nil

  attr_reader :name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    @name = base_name
    extract_options
  end

  def manifest
    record do |m|
      BASEDIRS.each { |path| m.directory path }

      # Rake tasks
      m.template "platform.rake", "lib/tasks/platform.rake"
      
      # Install desert dependency 
      require_desert_on_environment("#{destination_root}/config/environment.rb") 

      # PLugins 
      plugins = install_default_plugins

      # Migrations
      m.migration_template 'integrate_tog.rb', 'db/migrate', :assigns => {
        :migration_name => "IntegrateTog",
        :plugins => plugins
      },:migration_file_name => 'integrate_tog'
    end
  end

  protected
    def banner
      <<-EOS
Apply tog platform to an existing Rails app

USAGE: #{spec.name} name
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |options[:author]| }
      opts.on("--skip-tog_user",
             "Don't add tog_user in the tog integration process. Use this if you have a User model and signup process already working") { |v| options[:skip_tog_user] = v }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end

    def require_desert_on_environment(env_file)
      sentinel = 'Rails::Initializer.run do |config|'
      logger.create "require 'desert' on environment"
      unless options[:pretend]
        gsub_file env_file, /(#{Regexp.escape(sentinel)})/mi do |match|
          "require 'desert'\n#{match}\n  "
        end
      end
    end

    # Tog plugins
    def default_plugins
      plugins = %w{ tog_core tog_social tog_mail}
      plugins << "tog_user" unless options[:skip_tog_user]
    end
    
    def install_default_plugins
      installed_plugins = {}
      default_plugins.each{|plugin|
        plugin_path = "#{destination_root}/vendor/plugins/#{plugin}" 
        checkout_code(plugin_path, plugin)
        installed_plugins[plugin] = {:current_migration => current_migration_number(plugin_path)} 
        logger.create "vendor/plugins/#{plugin}"
        route_from_plugins("#{destination_root}/config/routes.rb", plugin)
      }
      installed_plugins
    end
    
    def checkout_code(plugin_path, plugin)
      repository = "git@github.com:tog/#{plugin}.git"
      revision = "head"
      
      command_line = [ "rm -rf #{plugin_path}",
        "git clone #{repository} #{plugin_path}"
      ].join(" && ")
      
      %x{#{command_line}}
    end
    def current_migration_number(plugin_path)
      Dir.glob("#{plugin_path}/db/migrate/*.rb").inject(0) do |max, file_path|
        n = File.basename(file_path).split('_', 2).first.to_i
        if n > max then n else max end
      end
    end

    def route_from_plugins(routes_file, plugin)
      sentinel = 'ActionController::Routing::Routes.draw do |map|'
      logger.route "map.routes_from_plugin #{plugin}"
      unless options[:pretend]
        gsub_file routes_file, /(#{Regexp.escape(sentinel)})/mi do |match|
          "#{match}\n  map.routes_from_plugin '#{plugin}'\n"
        end
      end
    end
    def gsub_file(path, regexp, *args, &block)
      content = File.read(path).gsub(regexp, *args, &block)
      File.open(path, 'wb') { |file| file.write(content) }
    end 

    BASEDIRS = %w(
      config
      db
      db/migrate
      lib
      lib/tasks
      vendor
      vendor/plugins
    )
end