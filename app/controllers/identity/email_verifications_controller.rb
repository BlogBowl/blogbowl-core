# TODO: PRO
# class Identity::EmailVerificationsController < ApplicationController
#   skip_before_action :authenticate, only: :show
#
#   before_action :set_user, only: :show
#
#   def show
#     @user.update! verified: true
#
#     # Here we add user to our subscribers
#     subscribe_user_to_newsletter(@user)
#
#     flash[:notice] = "Thank you for verifying your email address"
#     @workspace = @user.workspaces.first
#     redirect_to pages_ai_content_plan_path(@workspace.pages.first)
#   end
#
#   private
#     def set_user
#       @user = User.find_by_token_for!(:email_verification, params[:sid])
#     rescue StandardError
#       flash[:alert] = "That email verification link is invalid"
#       redirect_to edit_identity_email_path
#     end
#
#     def send_email_verification
#       UserMailer.with(user: current_user).email_verification.deliver_later
#     end
# end
