class Pages::Settings::GeneralController < Pages::Settings::ApplicationController
  def edit
  end

  def update
    if @page_settings.update(page_setting_params)
      flash[:notice] = "Page settings were updated successfully."
      redirect_to edit_pages_settings_general_path(page_id: @page_settings.page.name_slug)
    else
      flash.now[:alert] = @page_settings.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def page_setting_params
    params.require(:page_setting).permit(:seo_title, :seo_description, :title, :description, :og_image, :remove_og_image, :favicon, :remove_favicon, page_attributes: [:name, :slug])
  end
end

