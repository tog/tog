namespace :tog do
  namespace :update do
    desc "Update the tog plugins on this app"
    task :plugins do
      deps = %w(tog_core tog_mail tog_user tog_social)
      require 'rubygems'
      require 'rubygems/gem_runner'
      Gem.manage_gems

      rails = (version = ENV['VERSION']) ?
        Gem.cache.find_name('rails', "= #{version}").first :
        Gem.cache.find_name('rails').sort_by { |g| g.version }.last

      version ||= rails.version

      unless rails
        puts "No rails gem #{version} is installed.  Do 'gem list rails' to see what you have available."
        exit
      end

      puts "Updating the tog plugins in your vendor/plugins directory"
      rm_rf   "vendor/rails"
      mkdir_p "vendor/rails"

      begin
        chdir("vendor/plugins") do
          rails.dependencies.select { |g| deps.include? g.name }.each do |g|
            Gem::GemRunner.new.run(["unpack", g.name, "--version", g.version_requirements.to_s])
            mv(Dir.glob("#{g.name}*").first, g.name)
          end

          Gem::GemRunner.new.run(["unpack", "rails", "--version", "=#{version}"])
          FileUtils.mv(Dir.glob("rails*").first, "railties")
        end
      rescue Exception
        rm_rf "vendor/rails"
        raise
      end
    end
  end
end
namespace :tog do
  namespace :platform do
  end
  namespace :test do
    desc "Runs tests on all available Tog Plugins. Pass PLUGIN=plugin_name to test a single plugin"
    task :plugins do
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
    desc "List the names of tog plugins test methods in a specification like format. Pass PLUGIN=plugin_name to list a single plugin"
    task :list_specs do
      require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
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
  roots = Dir[File.dirname(__FILE__)+'/../../vendor/plugins/tog_*']
  if plugin
    roots = roots.select {|x| /\/(\d+_)?#{plugin}$/ === x }
    if roots.empty?
      puts "Sorry, the plugin '#{plugin}' is not installed."
    end
  end
  roots
end