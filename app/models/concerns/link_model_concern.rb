module LinkModelConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :page

    scope :footer, -> { where(location: 'footer') }
    scope :header, -> { where(location: 'header') }
  end

end