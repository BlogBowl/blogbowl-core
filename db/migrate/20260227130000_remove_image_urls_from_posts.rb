class RemoveImageUrlsFromPosts < ActiveRecord::Migration[8.0]
  def change
    remove_column :posts, :cover_image_url, :string
    remove_column :posts, :og_image_url, :string
  end
end
