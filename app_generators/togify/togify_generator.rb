require 'tog'
require 'zip/zip'

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

      # Include tog rake tasks on the app
      include_tog_rake_tasks("#{destination_root}/Rakefile")

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
      opts.on("--development",
             "Clone the repositories from the private clone urls allowing the developers to develop the plugins on a togified app.") { |v| options[:development] = v }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end

    def include_tog_rake_tasks(rakefile)
      sentinel = "require 'tasks/rails'"
      logger.create "require tog rake tasks"
      unless options[:pretend]
        gsub_file rakefile, /(#{Regexp.escape(sentinel)})/mi do |match|
          "#{match}\n\nrequire 'tasks/tog'\n"
        end
      end

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
      plugins = %w{ tog_core }
      plugins << "tog_user" unless options[:skip_tog_user]
      plugins += %w{tog_social tog_mail}
    end

    def install_default_plugins
      default_plugins.collect{|plugin|
        plugin_path = "#{destination_root}/vendor/plugins/#{plugin}"
        checkout_code(plugin_path, plugin)
        logger.create "vendor/plugins/#{plugin}"
        route_from_plugins("#{destination_root}/config/routes.rb", plugin)
        {:name => plugin,:current_migration => current_migration_number(plugin_path) }
      }
    end

    def checkout_code(plugin_path, plugin)
      options[:development] ? clone_repo(plugin_path, plugin): tarball_repo(plugin_path, plugin)
    end
    # "vendor/plugins/tog_core", "tog_core"
    def tarball_repo(plugin_path, plugin)
      uri = "http://github.com/tog/#{plugin}/zipball/v#{Tog::Version::STRING}"
      zip = tarball_fetch(uri)
      tarball_unpack(zip, plugin)
    end
    
    def tarball_fetch(uri, redirect_limit = 10)
      raise ArgumentError, "HTTP redirect too deep trying to get #{url}" if redirect_limit == 0
      response = Net::HTTP.get_response(URI.parse(uri))
      case response
      when Net::HTTPSuccess
        temp_zip = Time.now.to_i.to_s
        open(temp_zip, "wb") { |file|
          file.write(response.read_body)
        }
        temp_zip
      when Net::HTTPRedirection then tarball_fetch(response['location'], redirect_limit - 1)
      else
        tarball_fetch(uri, redirect_limit - 1)
      end
    end
    
    def tarball_unpack(file, plugin)
      destination = "#{destination_root}/vendor/plugins"
      begin
        Zip::ZipFile.open(file) { |zip_file|
         zip_file.each { |f|
           f_path=File.join(destination, f.name)
           FileUtils.mkdir_p(File.dirname(f_path))
           zip_file.extract(f, f_path) unless File.exist?(f_path)
         }
        }
        temp = Dir.glob(File.join(destination, "tog-#{plugin}*")).first
        FileUtils.mv temp, File.join(destination, plugin)
        FileUtils.rm_rf file
        
      rescue Exception => e
        logger.error "There has been a problem trying to unpack the #{plugin} tarball downloaded from github. Remove the changes made on your app by togify and try again. Sorry for the inconveniences."
        exit -1
      end
    end
    
    def clone_repo(plugin_path, plugin)
      repository = "git@github.com:tog/#{plugin}.git"
      revision = "head"
      FileUtils.rm_rf(plugin_path)
      system("git clone #{repository} #{plugin_path}")
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