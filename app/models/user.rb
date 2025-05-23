class User < ApplicationRecord
  include AvatarHelper

  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :members, dependent: :destroy
  has_many :workspaces, through: :members, source: :workspace

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 8 }

  def formatted_name
    email
  end

  def avatar(size: 1)
    initials = email[0].upcase + email[1].upcase
    avatar_placeholder(size: size, initials: initials)
  end
end
