class Routes < ActiveRecord::Migration
  def up
    create_table :bus_routes do |t|
      t.string :tag
      t.string :title

      t.timestamps
    end

  end

  def down
    drop_table :bus_routes
  end
end
