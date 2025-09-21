module Models::UserConcern
  extend ActiveSupport::Concern

  included do
    include AvatarHelper
    has_secure_password

    generates_token_for :email_verification, expires_in: 2.days do
      email
    end
    generates_token_for :password_reset, expires_in: 20.minutes do
      password_salt.last(10)
    end
    has_many :sessions, dependent: :destroy

    has_many :members, dependent: :destroy
    has_many :workspaces, through: :members, source: :workspace

    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    validates :first_name, length: { maximum: 25, allow_nil: true }
    validates :last_name, length: { maximum: 25, allow_nil: true }

    attr_accessor :skip_workspace_creation

    normalizes :email, with: -> { _1.strip.downcase }

    after_create :after_create, unless: :skip_workspace_creation
  end

  def formatted_name
    return email if first_name.blank? && last_name.blank?
    "#{first_name} #{last_name}"
  end

  def avatar(size: 1)
    return avatar_placeholder(size: size, initials: "AA") if email.blank?
    initials = email[0].upcase + email[1].upcase
    initials = [first_name, last_name].map { _1[0].upcase }.join if first_name.present? && last_name.present?

    avatar_placeholder(size: size, initials: initials)
  end

  def using_default_password?
    BCrypt::Password.new(password_digest) == 'changeme'
  end

  def notice_dismissed?(key)
    dismissed_notices[key.to_s].present?
  end

  private

  def after_create
    workspace = Workspace.new(title: "My Workspace")
    members.create!(workspace:, permissions: ["owner"])
    author = members.first.create_or_activate_author!

    # This creates default published post
    first_page = workspace.pages.first
    unless first_page.nil?
      first_page.create_default_first_post(author.id)
    end
  end
end