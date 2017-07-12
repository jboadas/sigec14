class CreateCablogins < ActiveRecord::Migration
  def self.up
    create_table :cablogins do |t|
    end
  end

  def self.down
    drop_table :cablogins
  end
end
