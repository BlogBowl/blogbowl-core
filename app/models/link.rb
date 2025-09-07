class Link < ApplicationRecord
  belongs_to :page

  scope :footer, -> { where(location: 'footer') }
  scope :header, -> { where(location: 'header') }
end
