class Member < ApplicationRecord
  belongs_to :user
  belongs_to :workspace

  has_one :author
  has_many :posts, through: :author

  validate :writer_must_have_active_author

  def create_or_activate_author!
    author.update!(active: true) and return if author.present?
    Author.create!(member: self, email: user.email, active: true)
  end

  def deactivate_author!
    author&.update!(active: false)
  end

  def roles
    roles = []
    roles << "posts:#{posts_role}" if posts_role
    roles
  end

  def posts_role
    return "editor" if (Post::EDITOR_PERMISSIONS - permissions).empty?
    "writer" if (Post::WRITER_PERMISSIONS - permissions).empty?
  end

  def posts_owns_author?
    author&.active?
  end

  def owner?
    permissions.include?("owner")
  end

  def formatted_name
    user.formatted_name
  end

  def avatar
    user.avatar
  end

  private

  def writer_must_have_active_author
    if posts_role == "writer" && !posts_owns_author?
      errors.add(:base, "Writer can't be without an author")
    end
  end
end
