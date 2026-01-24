class AddSchedulingToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :scheduled_at, :datetime
    add_column :posts, :job_id, :string

    add_index :posts, :job_id, unique: true
  end
end
