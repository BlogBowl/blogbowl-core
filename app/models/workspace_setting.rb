class WorkspaceSetting < ApplicationRecord
  belongs_to :workspace
  accepts_nested_attributes_for :workspace, update_only: true
end
