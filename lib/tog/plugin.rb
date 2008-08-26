module Tog
  class Plugin
    
    attr_reader :app_root, :plugin_name
    def initialize(app, plugin)
       @app_root = app
       @plugin_name = plugin
    end
    def install
      destination = "#{app_root}/vendor/plugins/#{plugin_name}" 
      repository = "git@github.com:tog/#{plugin_name}.git"
      revision = "head"
      
      command_line = [ "rm -rf #{destination}",
        "git clone #{repository} #{destination}",
        "cd #{destination}",
        "git checkout -f -b installed-#{revision} #{revision}"
      ].join(" && ")
      
      %x{#{command_line}}

      add_plugin_routes_to_app
      puts "[#{plugin_name}] installed!"
    end
    def update
      raise "Update plugin not implemented."
    end
    
    protected
    def add_plugin_routes_to_app
      sentinel = 'ActionController::Routing::Routes.draw do |map|'
      puts "[#{plugin_name}] routes added to config/routes.rb"
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
          "#{match}\n  map.routes_from_plugin :#{plugin_name}\n"
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
    
  end
end