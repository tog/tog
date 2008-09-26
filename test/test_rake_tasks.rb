require File.join(File.dirname(__FILE__), "test_generator_helper.rb")
require "rake"

class TestRakeTasks < Test::Unit::TestCase
  include RubiGen::GeneratorTestHelper

  def setup
    setup_fake_tog_app
    run_generator('togify', [APP_ROOT], sources)
    @rake = Rake::Application.new
    Rake.application = @rake
    load File.join(File.dirname(__FILE__), "..", "lib", "tasks", "platform.rake")

    @tog_core_resources_on_public = File.join(APP_ROOT, "public", "tog_core")
  end

  def teardown
    teardown_fake_tog_app
  end

  def test_copy_resources
    @rake["tog:plugins:copy_resources"].invoke
    assert File.exists?(@tog_core_resources_on_public)
  end

  def test_copy_resources_not_copy_svn_dirs
    svn_dir_on_tog_core = File.join(APP_ROOT, "vendor", "plugins", "tog_core", "public", ".svn")
    FileUtils.mkdir_p(svn_dir_on_tog_core)
    assert File.exists?(svn_dir_on_tog_core)

    @rake["tog:plugins:copy_resources"].invoke

    assert !File.exists?(File.join(@tog_core_resources_on_public, ".svn"))
  end


  private
  def sources
    [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path))]
  end

  def generator_path
    "app_generators"
  end

end
