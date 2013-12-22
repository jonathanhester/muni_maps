class Directions < ActiveRecord::Migration

  def up
    create_table :directions do |t|
      t.string :tag
      t.string :title
      t.string :name
      t.references :bus_stops

      t.timestamps
    end
  end

  def down
    drop_table :directions
  end
end
