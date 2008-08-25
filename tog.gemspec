Gem::Specification.new do |s|
  s.name     = "tog"
  s.version  = "0.2.6"
  
  s.date     = "2008-09-01"
  s.summary  = "tog: extensible open source social network platform"
  s.email    = "info@toghq.com"
  s.executables = ["togify"]
  
  s.homepage = "http://github.com/tog/tog"
  s.description = "extensible open source social network platform"
  s.has_rdoc = true
  s.authors  = ["Roberto Salicio", "Alberto Molpeceres", "Aitor Garcia"]
  s.files    = ["bin/togify",
    "README.rdoc", 
		"tog.gemspec",
		"lib/tog.rb",
		"lib/tog/install.rb",
		"lib/tog/plugin.rb",
	  "templates/lib/tasks/platform.rake.tpl"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc"]
end