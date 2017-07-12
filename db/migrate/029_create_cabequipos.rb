class CreateCabequipos < ActiveRecord::Migration
  def self.up
    create_table :cabequipos do |t|
    end
  end

  def self.down
    drop_table :cabequipos
  end
end
