class Stops < ActiveRecord::Migration

  def up
    create_table :stops do |t|
      t.string :tag
      t.string :title
      t.string :short_title
      t.float :lat
      t.float :lng
      t.string :stop_id

      t.timestamps
    end
  end

  def down
    drop_table :stops
  end
end
