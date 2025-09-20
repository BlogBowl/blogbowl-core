class User < ApplicationRecord
  include Models::UserConcern

  validates :password, allow_nil: false, length: { minimum: 8 }
end
