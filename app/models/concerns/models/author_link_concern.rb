module Models::AuthorLinkConcern
  extend ActiveSupport::Concern


  included do
    belongs_to :author
  end

end
