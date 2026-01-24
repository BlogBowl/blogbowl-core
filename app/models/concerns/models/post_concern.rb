module Models::PostConcern
  extend ActiveSupport::Concern

  included do
    include ConvertToWebp

    default_scope { where(archived_at: nil) }

    EDITOR_PERMISSIONS = %w[posts:create posts:edit posts:destroy]
    WRITER_PERMISSIONS = %w[posts:create posts:edit_own posts:update_own]
    OWNER_PERMISSIONS = %w[owner]

    belongs_to :page
    belongs_to :category, optional: true
    has_many :post_revisions, dependent: :destroy

    has_many :post_authors, dependent: :destroy
    has_many :authors, -> { where(post_authors: { role: 'author' }) }, through: :post_authors
    has_many :reviewers, -> { where(post_authors: { role: 'reviewer' }) }, through: :post_authors, source: :author

    before_validation :generate_slug, if: :should_generate_slug?
    validates :title, presence: true, length: { minimum: 1 }, if: :published?
    validates :slug, presence: true, uniqueness: { scope: :page_id }
    validates :authors, presence: true, if: :published?

    enum :status, { draft: 0, published: 1, scheduled: 2 }

    scope :published, -> { where(status: :published).order(first_published_at: :desc) }

    has_many_attached :images
    has_one_attached :cover_image
    has_one_attached :sharing_image

    convert_to_webp_for :images
    convert_to_webp_for :cover_image
    convert_to_webp_for :sharing_image

    def self.permissions_of_role(role)
      case role
      when "editor"
        Post::EDITOR_PERMISSIONS
      when "writer"
        Post::WRITER_PERMISSIONS
      when "owner"
        Post::OWNER_PERMISSIONS
      else
        []
      end
    end
  end

  def to_param
    slug
  end

  def publish!
    self.transaction do
      post_revision = post_revisions.last
      post_revision&.apply!

      update!(
        status: :published,
        first_published_at: first_published_at || Time.current
      )
      post_revision&.update!(kind: :history)
    end
  end

  def content_sanitized
    tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p img)
    ActionController::Base.helpers.sanitize(content_html, tags: tags, attributes: %w(href title alt src))
  end

  def new_revision
    last_revision = post_revisions.last
    second_to_last_revision = post_revisions.second_to_last
    if last_revision.present?
      if second_to_last_revision.present? && last_revision.equals?(second_to_last_revision)
        # return last revision if it's the same as the pre-last one
        last_revision
      else
        last_revision.dup.tap do |revision|
          revision.kind = :draft
          revision.share_id = nil
          revision.shared_at = nil
        end
      end
    else
      new_draft_revision
    end
  end

  def as_json(options = nil)
    super(options).except(:content_html, :content_json, :category_id)
                  .merge(category_id: category_ids[:category_id])
                  .merge(cover_image: cover_image.attached? ? Rails.application.routes.url_helpers.url_for(cover_image) : nil)
                  .merge(sharing_image: sharing_image.attached? ? Rails.application.routes.url_helpers.url_for(sharing_image) : nil)
                  .merge(authors: filtered_authors('author'),
                         reviewers: filtered_authors('reviewer'))
  end

  def archived?
    archived_at.present?
  end

  private

  def new_draft_revision
    attributes = { title: title, kind: :draft }

    attributes[:content_html] = content_html if content_html.present?
    attributes[:content_json] = content_json if content_json.present?
    attributes[:seo_title] = seo_title if seo_title.present?
    attributes[:seo_description] = seo_description if seo_description.present?
    attributes[:og_title] = og_title if og_title.present?
    attributes[:og_description] = og_description if og_description.present?

    post_revisions.new(attributes)
  end

  def category_ids
    if category.present?
      { category_id: category_id }
    else
      { category_id: nil }
    end
  end

  def should_generate_slug?
    title_changed? && (new_record? || !published?)
  end

  def filtered_authors(type)
    self.authors.where(post_authors: { role: type }).map { |author| author.as_json(only: [:id, :first_name, :last_name, :email]).merge(avatar: author.avatar_url) }
  end

  def generate_slug
    return if title.blank?

    base_slug = title.parameterize
    potential_slug = base_slug
    count = 1

    while Post.unscoped.exists?(slug: potential_slug, page_id: page_id)
      potential_slug = "#{base_slug}-#{count}"
      count += 1
    end

    self.slug = potential_slug
  end
end
