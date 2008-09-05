namespace :tog do
  namespace :plugins do
    desc "Update the tog plugins on this app."
    task :update do
      plugin_roots(ENV["PLUGIN"]).each do |directory|
        puts "Pulling changes of #{File.basename(directory)}"
        chdir directory do
           output = %x{git pull}
        end
      end
    end
    desc "Install a new tog plugin. Use PLUGIN parameter to specify the plugin to install e.g. PLUGIN=tog_vault. Use FORCE=true to overwrite the plugin if it's currently installed."
    task :install do
      plugin = ENV["PLUGIN"]
      force = ENV["FORCE"] || false
      puts "Installing #{plugin} on vendor/plugins/#{plugin}"
      cmd = "script/plugin install git@github.com:tog/#{plugin}.git"
      cmd << " --force" if force
      output = %x{#{cmd}}
      puts "Generating migration to integrate #{plugin} in the app"
      
      to_version=Dir.glob("#{RAILS_ROOT}/vendor/plugins/#{plugin}/db/migrate/*.rb").inject(0) do |max, file_path|
        n = File.basename(file_path).split('_', 2).first.to_i
        if n > max then n else max end
      end
      from_version=0
      cmd = "script/generate tog_migration Integrate#{plugin.classify}Version#{to_version}From#{from_version}"
      output = %x{#{cmd}}
      
    end

    desc "Copy the public resources stored on the /public folder of every tog plugin on the app's public folder with the plugin name used as prefix. Pass PLUGIN=plugin_name to copy the resources of a single plugin."
    task :copy_resources do
      plugin_roots(ENV["PLUGIN"]).each do |directory|
        plugin_name = File.basename(directory) 
        dest_public_dir = File.join(RAILS_ROOT, "public", plugin_name)
        orig_public_dir = File.join(directory, "public")
        if File.exists?(orig_public_dir)
          puts "Copying the public resources of #{plugin_name} to #{dest_public_dir}"
          FileUtils.mkdir_p(dest_public_dir)
          FileUtils.cp_r(Dir["#{orig_public_dir}/*"], dest_public_dir )
        end
      end
    end

    desc "Runs tests on all available Tog Plugins. Pass PLUGIN=plugin_name to test a single plugin."
    task :test do
      plugin_roots(ENV["PLUGIN"]).each do |directory|
        if File.directory?(File.join(directory, 'test'))
          chdir directory do
            if RUBY_PLATFORM =~ /win32/
              system "rake.cmd test"
            else
              system "rake test"
            end
          end
        end
      end
    end
    desc "List the names of tog plugins test methods in a specification like format. Pass PLUGIN=plugin_name to list a single plugin."
    task :list_specs do
      require File.expand_path(File.join(RAILS_ROOT, "config","environment"))
      require 'test/unit'
      require 'rubygems'
      require 'active_support'
      
      # bug in test unit.  Set to true to stop from running.
      Test::Unit.run = true

      plugin_roots(ENV["PLUGIN"]).each do |directory|
        if File.directory?(File.join(directory, 'test'))
          chdir directory do
            test_files = Dir.glob(File.join('test', '**', '*_test.rb'))
            test_files.each do |file|
              load file
              klass = File.basename(file, '.rb').classify.constantize

              puts klass.name.gsub('Test', '')

              test_methods = klass.instance_methods.grep(/^test/).map {|s| s.gsub(/^test: /, '')}.sort
              test_methods.each {|m| puts "  " + m }
            end
          end
        end
      end
    end
  end
end

def plugin_roots(plugin=nil)
  roots = Dir[File.join(RAILS_ROOT, 'vendor', 'plugins', 'tog_*')]
  if plugin
    roots = roots.select {|x| /\/(\d+_)?#{plugin}$/ === x }
    if roots.empty?
      puts "Sorry, the plugin '#{plugin}' is not installed."
    end
  end
  roots
end