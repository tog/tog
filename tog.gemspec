Gem::Specification.new do |s|
  s.name = %q{tog}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aitor Garc\303\255a", "Alberto Molpeceres", "Roberto Salicio"]
  s.date = %q{2008-09-24}
  s.default_executable = %q{togify}
  s.description = %q{extensible open source social network platform}
  s.email = ["aitor@linkingpaths.com", "alberto@linkingpaths.com", "roberto@linkingpaths.com"]
  s.executables = ["togify"]
  s.extra_rdoc_files = ["Manifest.txt", "README.txt"]
  s.files = ["CHANGELOG.md", "MIT-LICENSE", "Manifest.txt", "POST_INSTALL", "README.txt", "Rakefile", "app_generators/togify/USAGE", "app_generators/togify/templates/integrate_tog.rb", "app_generators/togify/togify_generator.rb", "bin/togify", "config/hoe.rb", "config/requirements.rb", "generators/tog_migration/USAGE", "generators/tog_migration/templates/migration.rb", "generators/tog_migration/tog_migration_generator.rb", "generators/tog_plugin/USAGE", "generators/tog_plugin/tog_plugin_generator.rb", "lib/tasks/platform.rake", "lib/tasks/tog.rb", "lib/tog.rb", "lib/tog/version.rb", "test/templates/Rakefile", "test/templates/environment.rb", "test/templates/routes.rb", "test/test_generator_helper.rb", "test/test_helper.rb", "test/test_tog.rb", "test/test_tog_plugin_generator.rb", "test/test_togify_generator.rb", "tog.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/tog/tog}
  s.post_install_message = %q{
For more information on tog, see https://github.com/tog/tog

}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{tog}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{extensible open source social network platform}
  s.test_files = ["test/test_generator_helper.rb", "test/test_helper.rb", "test/test_tog.rb", "test/test_tog_plugin_generator.rb", "test/test_togify_generator.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<mislav-will_paginate>, [">= 2.3.2"])
      s.add_runtime_dependency(%q<tog-desert>, [">= 0.3.4"])
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<mislav-will_paginate>, [">= 2.3.2"])
      s.add_dependency(%q<tog-desert>, [">= 0.3.4"])
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<mislav-will_paginate>, [">= 2.3.2"])
    s.add_dependency(%q<tog-desert>, [">= 0.3.4"])
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
