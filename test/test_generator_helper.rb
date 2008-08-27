begin
  require File.dirname(__FILE__) + '/test_helper'
rescue LoadError
  require 'test/unit'
end
require 'fileutils'

# Must set before requiring generator libs.
TMP_ROOT = File.dirname(__FILE__) + "/tmp" unless defined?(TMP_ROOT)
PROJECT_NAME = "tog" unless defined?(PROJECT_NAME)
app_root = File.join(TMP_ROOT, PROJECT_NAME)
if defined?(APP_ROOT)
  APP_ROOT.replace(app_root)
else
  APP_ROOT = app_root
end
if defined?(RAILS_ROOT)
  RAILS_ROOT.replace(app_root)
else
  RAILS_ROOT = app_root
end

begin
  require 'rubigen'
rescue LoadError
  require 'rubygems'
  require 'rubigen'
end
require 'rubigen/helpers/generator_test_helper'

def copy_to_fake (orig, dest)
  FileUtils.cp(File.join(File.dirname(__FILE__), orig), File.join(APP_ROOT, dest))
end
def setup_fake_tog_app
  bare_setup
  FileUtils.mkdir_p(File.join(APP_ROOT, "/config"))
  copy_to_fake("/templates/environment.rb", "/config/environment.rb")
  copy_to_fake("/templates/routes.rb", "/config/routes.rb")
  @plugins = %w{ tog_core tog_social tog_mail tog_user}  
end
def teardown_fake_tog_app
  bare_teardown
end
  
def assert_has_require(body,*requires)
  requires.each do |req|
    assert body=~/require '#{req.to_s}'/,"should have require '#{req.to_s}'"
    yield( req, $1 ) if block_given?
  end
end

def assert_has_plugin_routes(body,*routes)
  routes.each do |route|
    assert body=~/map.routes_from_plugin '#{route.to_s}'/,"should have routes '#{route.to_s}'"
    yield( route, $1 ) if block_given?
  end
end
