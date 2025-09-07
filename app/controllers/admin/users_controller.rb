class Admin::UsersController < ApplicationController
  before_action :authorize_admin
  layout 'dashboard'
  include Pagy::Backend

  def index
    users = User.left_joins(:sessions)
                .select('users.*, MAX(sessions.created_at) as last_sign_in_at')
                .group('users.id')
                .order('MAX(sessions.created_at) DESC NULLS LAST')

    if params[:search].present?
      users = users.where("email ILIKE ?", "%#{params[:search].strip}%")
    end

    @pagy, @users = pagy(users, page: params[:page] || 1, limit: 20)
  end

  private

  def authorize_admin
    unless current_user&.email&.ends_with?('@blogbowl.io')
      redirect_to root_path
    end
  end
end
