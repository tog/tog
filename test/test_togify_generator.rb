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

    assert_generated_file   "lib/tasks/platform.rake"
    assert_generated_file "config/environment.rb" do |body|
      assert_has_require body, 'desert'
    end
    
    @plugins.each{|plugin|
      assert_directory_exists("vendor/plugins/#{plugin}")
      assert_generated_file "config/routes.rb" do |body|
        assert_has_plugin_routes body, plugin
      end
    }
  end


  private
  def sources
    [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path))]
  end

  def generator_path
    "app_generators"
  end
end
