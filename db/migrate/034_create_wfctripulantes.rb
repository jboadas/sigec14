class CreateWfctripulantes < ActiveRecord::Migration
  def self.up
    create_table :wfctripulantes do |t|
    end
  end

  def self.down
    drop_table :wfctripulantes
  end
end
