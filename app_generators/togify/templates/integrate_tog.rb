class <%= migration_name %> < ActiveRecord::Migration
  def self.up<% plugins.each_pair do |plugin, details| %>
    migrate_plugin "<%= plugin %>", <%= details[:current_migration] %><%- end %>
  end

  def self.down<% plugins.each_pair do |plugin, details| %>
    migrate_plugin "<%= plugin %>", 0 <%- end %>
  end
end
