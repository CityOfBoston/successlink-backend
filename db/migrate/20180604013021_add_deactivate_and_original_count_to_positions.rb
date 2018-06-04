class AddDeactivateAndOriginalCountToPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :positions, :active, :boolean, default: true
    add_column :positions, :original_position_count, :integer
  end
end
