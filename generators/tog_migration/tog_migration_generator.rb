class TogMigrationGenerator < Rails::Generator::NamedBase  
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :assigns => get_local_assigns
    end
  end

  
  private  
    def get_local_assigns
      returning(assigns = {}) do
        if class_name.underscore =~ /^integrate_(.*)_(?:version)(.*)_(?:from)(.*)/
          assigns[:plugins] = [{:name => $1, :to_version => $2, :from_version => $3 }]
        else
          assigns[:plugins] = []
        end
      end
    end
end
