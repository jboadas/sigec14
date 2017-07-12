class CreateCabvuelos < ActiveRecord::Migration
  def self.up
    create_table :cabvuelos do |t|
    end
  end

  def self.down
    drop_table :cabvuelos
  end
end
