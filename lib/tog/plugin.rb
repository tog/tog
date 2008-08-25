module Tog
  class Plugin
    def install(app, plugin)
      destination = "#{app}/vendor/plugins/#{plugin}" 
      repository = "git@github.com:tog/#{plugin}.git"
      revision = "head"
      
      command_line = [ "rm -rf #{destination}",
        "git clone #{repository} #{destination}",
        "cd #{destination}",
        "git checkout -f -b installed-#{revision} #{revision}"
      ].join(" && ")
      
      %x{#{command_line}}
      
    end
    def update(app, plugin)
      raise "Update plugin not implemented."
    end
  end
end