class PasswordsController < ApplicationController
  layout false
  before_action :set_user

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:notice] = "Your password has been changed"
      redirect_to root_path
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = current_user
    end

    def user_params
      params.permit(:password, :password_confirmation, :password_challenge).with_defaults(password_challenge: "")
    end
end
