class User < ApplicationRecord
  include UserModelConcern

  validates :password, allow_nil: false, length: { minimum: 8 }
end
