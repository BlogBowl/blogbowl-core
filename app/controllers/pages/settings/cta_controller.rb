class Pages::Settings::CtaController < Pages::Settings::ApplicationController
  def edit
  end

  def update
    if @page_settings.update(page_setting_params)
      flash[:notice] = "Blog settings were updated successfully."
      redirect_to edit_pages_settings_cta_path
    else
      flash.now[:alert] = @page_settings.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def page_setting_params
    params.require(:page_setting).permit(
      :cta_title,
      :cta_description,
      :cta_button,
      :cta_button_link,
      :cta_enabled,
    )
  end

end

