class <%= migration_name %> < ActiveRecord::Migration
  def self.up<% plugins.each do |plugin| %>
    migrate_plugin "<%= plugin[:name] %>", <%= plugin[:current_migration] %><%- end %>
  end

  def self.down<% plugins.reverse.each do |plugin| %>
    migrate_plugin "<%= plugin[:name] %>", 0 <%- end %>
  end
end
