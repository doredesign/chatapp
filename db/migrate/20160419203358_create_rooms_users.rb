class CreateRoomsUsers < ActiveRecord::Migration
  def change
    create_table :rooms_users do |t|
      t.belongs_to :user, index: true
      t.belongs_to :room, index: true
    end
  end
end
