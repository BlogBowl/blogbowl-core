class Newsletters::Settings::GeneralController < Newsletters::Settings::ApplicationController

  def edit
  end

  def update
    if @newsletter_settings.update(newsletter_setting_params)
      flash[:notice] = "Newsletter settings were updated successfully."
      edit_newsletters_settings_general_path
      redirect_to edit_newsletters_settings_general_path(@newsletter)
    else
      flash.now[:alert] = @newsletter_settings.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def newsletter_setting_params
    params.require(:newsletter_setting).permit(:footer, :logo, :remove_logo, newsletter_attributes: [:name])
  end

end