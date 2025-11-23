class Settings::APITokensController < Settings::ApplicationController
  before_action :set_api_token, only: [:destroy]

  def index
    @api_tokens = @workspace.api_tokens.order(created_at: :desc)
  end

  def create
    @api_token = @workspace.api_tokens.new(api_token_params.merge(user: current_user))
    if @api_token.save
      flash[:notice] = "API token was created successfully."
      redirect_to settings_api_tokens_path
    else
      flash[:alert] = @api_token.errors.full_messages.to_sentence
      redirect_to settings_api_tokens_path
    end
  end

  def destroy
    @api_token.destroy
    flash[:notice] = "API token was deleted successfully."
    redirect_to settings_api_tokens_path
  end

  private

  def api_token_params
    params.require(:api_token).permit(:name)
  end

  def set_api_token
    @api_token = @workspace.api_tokens.find(params[:id])
  end
end
