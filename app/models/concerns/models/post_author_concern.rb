module Models::PostAuthorConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :post
    belongs_to :author

    validate :author_is_member_of_page
    validates :role, presence: true

    enum :role, { author: 0, reviewer: 1 }
  end

  private

  def author_is_member_of_page
    return if post.page.workspace == author.member.workspace

    errors.add(:author, "is not a member of the blog")
  end

end