require File.join(File.dirname(__FILE__), "test_generator_helper.rb")

class TestTogifyGenerator < Test::Unit::TestCase
  include RubiGen::GeneratorTestHelper

  def setup
    setup_fake_tog_app
  end

  def teardown
    teardown_fake_tog_app
  end

  def test_generator_without_options
    run_generator('togify', [APP_ROOT], sources)

    assert_generated_file "Rakefile" do |body|
      assert_has_require body, 'tasks/tog'
    end
    
    assert_generated_file "config/environment.rb" do |body|
      assert_has_require body, 'desert'
    end
    
    @plugins.each{|plugin|
      assert_directory_exists("vendor/plugins/#{plugin}")
      assert_generated_file "config/routes.rb" do |body|
        assert_has_plugin_routes body, plugin
      end
      assert_remote_origin_of_plugin(plugin, "git://github.com/tog/(.*).git")
    }
    generated_migration = Dir.glob("#{APP_ROOT}/db/migrate/*_integrate_tog.rb")[0]
    assert generated_migration, "should be a IntegrateTog migration in the togified app"
    File.open(generated_migration, "r") do |file|
      assert file.read=~/tog_core.*tog_user.*tog_social.*tog_mail.*tog_mail.*tog_social.*tog_user.*tog_core/m,"plugins migrations should be in correct order"
    end
  end
  
  
  def test_generator_with_dev_repositories
    run_generator('togify', [APP_ROOT], sources, {:development => true})
    @plugins.each{|plugin|
      assert_remote_origin_of_plugin(plugin, "git@github.com:tog/(.*).git")
    }
  end
  
  private
  def sources
    [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path))]
  end

  def generator_path
    "app_generators"
  end

  def assert_remote_origin_of_plugin(plugin, match)
    FileUtils.chdir File.join(APP_ROOT, "vendor", "plugins", "#{plugin}") do
      remote_origin = %x{git config remote.origin.url}
      assert remote_origin.match(match)
    end
  end

end
