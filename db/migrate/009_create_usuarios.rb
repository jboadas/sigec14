class CreateUsuarios < ActiveRecord::Migration
  def self.up
    create_table :usuarios do |t|
    end
  end

  def self.down
    drop_table :usuarios
  end
end
