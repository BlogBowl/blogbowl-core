class PostRevision < ApplicationRecord
  belongs_to :post

  enum kind: { draft: 0, history: 1 }

  scope :drafts, -> { where(kind: :draft) }
  scope :history, -> { where(kind: :history) }

  def apply!
    post.update!(title:, content_html:, content_json:, seo_title:, seo_description:, og_title:, og_description:)
  end

  def equals?(revision)
    except = [:id, :post_id, :kind, :created_at, :updated_at]
    self.attributes.symbolize_keys.except(*except) == revision.attributes.symbolize_keys.except(*except)
  end

  def share
    update(share_id: SecureRandom.uuid, shared_at: Time.current)
  end
end
