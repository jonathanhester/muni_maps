class DirectionStops < ActiveRecord::Migration
  def up
    create_table :direction_stops do |t|
      t.references :direction
      t.references :stop

      t.timestamps
    end

  end

  def down
    drop_table :direction_stops
  end
end
