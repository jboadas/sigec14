class CreateWfcvolados < ActiveRecord::Migration
  def self.up
    create_table :wfcvolados do |t|
    end
  end

  def self.down
    drop_table :wfcvolados
  end
end
