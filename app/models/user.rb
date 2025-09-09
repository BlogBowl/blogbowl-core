class User < ApplicationRecord
  include AvatarHelper
  has_secure_password

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end
  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_many :sessions, dependent: :destroy
  # TODO: PRO
  # has_many :sign_in_tokens, dependent: :destroy
  # has_many :events, dependent: :destroy

  has_many :members, dependent: :destroy
  has_many :workspaces, through: :members, source: :workspace

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: false, length: { minimum: 8 }

  validates :first_name, length: { maximum: 25, allow_nil: true }
  validates :last_name, length: { maximum: 25, allow_nil: true }

  normalizes :email, with: -> { _1.strip.downcase }

  # before_validation if: :email_changed?, on: :update do
  #   self.verified = false
  # end

  after_create do
    workspace = Workspace.new(title: "My Workspace")
    members.create!(workspace:, permissions: ["owner"])
    author = members.first.create_or_activate_author!

    # This creates default published post
    first_page = workspace.pages.first
    unless first_page.nil?
      first_page.create_default_first_post(author.id)
    end

    # TODO: PRO
    # if verified? && provider.present?
    #   # start journey for oauth users
    #   # TODO: enable later
    #   # Journeys::NewRegistration.new(user_id: self.id).start
    # end
  end

  # TODO: PRO
  # after_update if: :password_digest_previously_changed? do
  #   sessions.where.not(id: Current.session).delete_all
  # end
  #
  # after_update if: :email_previously_changed? do
  #   events.create! action: "email_verification_requested"
  # end
  #
  # after_update if: :password_digest_previously_changed? do
  #   events.create! action: "password_changed"
  # end
  #
  # after_update if: [:verified_previously_changed?, :verified?] do
  #   events.create! action: "email_verified"
  #   Journeys::NewRegistration.new(user_id: self.id).start
  # end

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

  def notice_dismissed?(key)
    dismissed_notices[key.to_s].present?
  end
end
