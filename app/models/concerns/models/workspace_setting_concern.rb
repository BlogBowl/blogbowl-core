module Models::WorkspaceSettingConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :workspace
    accepts_nested_attributes_for :workspace, update_only: true

    # TODO: PRO
    # validate :free_plan_has_watermark
  end
  #
  # private
  #
  # def free_plan_has_watermark
  #   if workspace.free? && !with_watermark?
  #     errors.add(:base, "Watermark can't be removed from free plan")
  #   end
  # end


end