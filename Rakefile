require 'config/requirements'
require 'config/hoe' # setup Hoe + all gem configuration

namespace :manifest do
  desc 'Recreate Manifest.txt to include ALL files'
  task :refresh do
    `rake check_manifest | patch -p0 > Manifest.txt`
  end
end