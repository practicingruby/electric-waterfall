class CreateLetters < ActiveRecord::Migration
  def self.up
    create_table :letters do |t|
      t.belongs_to :template
      t.text :name
      t.text :body
    end
  end

  def self.down
    drop_table :letters
  end
end
