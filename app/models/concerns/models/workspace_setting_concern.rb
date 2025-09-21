module Models::WorkspaceSettingConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :workspace
    accepts_nested_attributes_for :workspace, update_only: true
  end
end