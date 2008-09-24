require 'tog/version'

DEVELOPERS = [
  ["Aitor García", "aitor@linkingpaths.com"],
  ["Alberto Molpeceres", "alberto@linkingpaths.com"],
  ["Roberto Salicio", "roberto@linkingpaths.com"]
]

GEM_NAME = 'tog'
EXTRA_DEPENDENCIES = [
  ['mislav-will_paginate', '>= 2.3.2'],
  ['tog-desert', '>= 0.3.4']
]

REV = nil
# UNCOMMENT IF REQUIRED:
# REV = YAML.load(`svn info`)['Revision']
VERS = Tog::VERSION::STRING + (REV ? ".#{REV}" : "")

class Hoe
  def extra_deps
    @extra_deps.reject! { |x| Array(x).first == 'hoe' }
    @extra_deps
  end
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new(GEM_NAME, VERS) do |p|
  DEVELOPERS.each{|dev|
    p.developer(dev[0], dev[1])
  }
  p.description = p.summary = "extensible open source social network platform"
  p.url = "http://github.com/tog/tog"
  p.test_globs = ["test/**/test_*.rb"]
  p.clean_globs |= ['**/.*.sw?', '*.gem', '.config', '**/.DS_Store']  #An array of file patterns to delete on clean.

  # == Optional
  p.post_install_message = File.open(File.dirname(__FILE__) + "/../POST_INSTALL").read rescue ""
  p.changes = p.paragraphs_of("CHANGELOG", 0..1).join("\n\n") rescue ""
  p.extra_deps = EXTRA_DEPENDENCIES
  #p.spec_extras = {}    # A hash of extra values to set in the gemspec.
end
