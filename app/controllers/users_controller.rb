# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def dismiss_notice
    key = params[:notice_key]
    current_user.dismissed_notices[key] = true
    if current_user.save
      head :ok # Respond with a success status and no body
    else
      head :unprocessable_entity
    end
  end
end