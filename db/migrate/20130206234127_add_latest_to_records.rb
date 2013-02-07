class AddLatestToRecords < ActiveRecord::Migration
  def change
    add_column :records, :latest, :boolean, :null => false, :default => true
  end
end
