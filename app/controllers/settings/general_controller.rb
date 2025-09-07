class Settings::GeneralController < Settings::ApplicationController
  def edit
  end

  def update
    if @workspace_settings.update(workspace_settings_params)
      flash[:notice] = "Workspace settings were updated successfully."
      redirect_to edit_settings_general_path
    else
      flash.now[:alert] = @workspace_settings.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def workspace_settings_params
    params.require(:workspace_setting).permit(:html_lang, :locale, :og_image, :favicon, :logo, :with_watermark, workspace_attributes: [:title])
  end
end