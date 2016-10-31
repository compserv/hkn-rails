class AddMarkdownToEvents < ActiveRecord::Migration
  def change
    add_column :events, :markdown, :boolean, default: false
  end
end
