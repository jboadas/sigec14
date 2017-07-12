class CreateCabpasajeros < ActiveRecord::Migration
  def self.up
    create_table :cabpasajeros do |t|
    end
  end

  def self.down
    drop_table :cabpasajeros
  end
end
