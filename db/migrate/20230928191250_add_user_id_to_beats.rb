class AddUserIdToBeats < ActiveRecord::Migration[7.0]
  def change
    add_reference :beats, :user, foreign_key: true
  end
end
