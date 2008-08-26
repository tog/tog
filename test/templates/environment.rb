RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION
require File.join(File.dirname(__FILE__), 'boot')
Rails::Initializer.run do |config|
  config.time_zone = 'UTC'
  config.action_controller.session = {
    :session_key => '_tog_app_session',
    :secret      => 'c06f15cbc11cb6b70d45df5f9b527aeb18003879c5527b734a862558e596dfc9c4e96e841a7ff5dd44c129aba275cf50f244301956347815699432ba3a1fd53a'
  }
end
