class APIToken < ApplicationRecord
  belongs_to :workspace
  belongs_to :user

  has_secure_token :token, length: 64

  validates :name, presence: true
end
