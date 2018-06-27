class AddEnumsToGameModel < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :state, :integer
    add_index :games, :state
  end
end
