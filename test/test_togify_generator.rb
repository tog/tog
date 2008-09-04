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

    assert_generated_file "lib/tasks/platform.rake"
    assert_generated_file "config/environment.rb" do |body|
      assert_has_require body, 'desert'
    end
    
    @plugins.each{|plugin|
      assert_directory_exists("vendor/plugins/#{plugin}")
      assert_generated_file "config/routes.rb" do |body|
        assert_has_plugin_routes body, plugin
      end
    }
    generated_migration = Dir.glob("#{APP_ROOT}/db/migrate/*_integrate_tog.rb")[0]
    assert generated_migration, "should be a IntegrateTog migration in the togified app"
    File.open(generated_migration, "r") do |file|
      assert file.read=~/tog_core.*tog_user.*tog_social.*tog_mail.*tog_mail.*tog_social.*tog_user.*tog_core/m,"plugins migrations should be in correct order"
    end
  end

  private
  def sources
    [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path))]
  end

  def generator_path
    "app_generators"
  end
end
