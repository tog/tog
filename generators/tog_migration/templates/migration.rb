class <%= class_name.underscore.camelize %> < ActiveRecord::Migration
  def self.up<% plugins.each do |plugin| %>
    migrate_plugin "<%= plugin[:name] %>", <%= plugin[:to_version] %><%- end %>
  end

  def self.down<% plugins.reverse.each do |plugin| %>
    migrate_plugin "<%= plugin[:name] %>", <%= plugin[:from_version] %><%- end %>
  end
end