class MakeActiveGameStateDefault < ActiveRecord::Migration[5.0]
  def change
    change_column :games, :state, :integer, default: 0
  end
end
