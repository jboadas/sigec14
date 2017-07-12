class CreateWfcvuelos < ActiveRecord::Migration
  def self.up
    create_table :wfcvuelos do |t|
    end
  end

  def self.down
    drop_table :wfcvuelos
  end
end
