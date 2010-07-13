class CreateTemplates < ActiveRecord::Migration
  def self.up
    create_table :templates do |t|
      t.text :source
      t.text :name
    end
  end

  def self.down
    drop_table :templates
  end
end
