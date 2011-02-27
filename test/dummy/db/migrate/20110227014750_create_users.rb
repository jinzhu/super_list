class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :gender
      t.string :gender1
      t.string :gender2

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
