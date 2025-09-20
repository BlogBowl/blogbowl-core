class User < ApplicationRecord
  include Model::UserModelConcern

  validates :password, allow_nil: false, length: { minimum: 8 }
end
