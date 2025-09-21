module Models::WorkspaceConcern
  extend ActiveSupport::Concern

  included do
    include AvatarHelper
    include Rails.application.routes.url_helpers

    has_many :pages, dependent: :destroy
    has_many :newsletters, dependent: :destroy
    has_many :members, dependent: :destroy
    has_many :authors, through: :members
    has_many :newsletter_emails, dependent: :destroy
    has_one :settings, dependent: :destroy, class_name: 'WorkspaceSetting'

    before_validation :generate_uuid, on: :create

    validates :title, presence: true

    after_create :after_create
  end

  def member_of_user(user)
    members.find_by(user_id: user.id)
  end

  def owner?(user)
    permissions(user).include?("owner")
  end

  def owner
    members.select { _1.owner? }.first
  end

  def permissions(user)
    members.find_by(user_id: user.id)&.permissions || []
  end

  def avatar
    avatar_placeholder(size: 1, initials: title[0])
  end

  def member_avatars(size: 1)
    return "" if members.empty? || members.count < 2
    avatars_html = members.take(4).map do |member|
      <<~HTML
        #{member.user.avatar(size:).html_safe}
      HTML
    end.join

    remaining_count = members.count - 4
    remaining_count = 0 if remaining_count < 1

    remaining_html = ""
    if remaining_count > 0
      remaining_html = avatar_placeholder(size: size, initials: "+#{remaining_count}")
    end

    <<~HTML
      <div class="avatar-group -space-x-6 rtl:space-x-reverse justify-center">
        #{avatars_html}
        #{remaining_html}
      </div>
    HTML
  end

  private

  def after_create
    # We create newsletter only if Postmark account token is present
    if FeatureGuard.enabled?(:postmark)
      newsletters.create!(workspace: self, name: 'Default Newsletter', name_slug: 'default-newsletter', uuid: uuid)
    end

    pages.create!(workspace: self, slug: 'blog', name: 'My blog')

    create_default_setting
  end

  def create_default_setting
    create_settings(
      html_lang: 'en',
      locale: 'en-US'
    )
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

end